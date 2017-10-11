package se.gunnebo.iot;

import com.amazonaws.services.iot.client.AWSIotDevice;
import com.amazonaws.services.iot.client.AWSIotException;
import com.amazonaws.services.iot.client.AWSIotMqttClient;
import com.amazonaws.services.iot.client.AWSIotTimeoutException;
import io.netty.handler.codec.http.HttpResponseStatus;
import io.reactivex.netty.protocol.http.server.HttpServer;
import org.apache.commons.cli.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import rx.Observable;

import java.util.Map;

public class LightBulbServer {
	private static Logger logger = LoggerFactory.getLogger(LightBulbServer.class);

	public static void main(String[] args) throws ParseException {
		final Map<String, String> env = System.getenv();

		final Options options = new Options();
		final CommandLineParser parser = new DefaultParser();

		options.addOption("e", "endpoint", true, "Client Endpoint");
		options.addOption("i", "access-key-id", true, "AWS Access Key Id");
		options.addOption("k", "secret-access-key", true, "AWS Secret Access Key");

		final CommandLine commandLine = parser.parse(options, args);
		final String clientEndpoint = commandLine.getOptionValue("e", env.getOrDefault("ENDPOINT", null));
		final String awsAccessKeyId = commandLine.getOptionValue("i", env.getOrDefault("ID", null));
		final String awsSecretAccessKey = commandLine.getOptionValue("k", env.getOrDefault("KEY", null));

		final String clientId = "lightbulbServer";
		System.out.println(String.format("Connection to: %s, %s, %s", clientEndpoint, awsAccessKeyId, awsSecretAccessKey));

		final AWSIotMqttClient awsIotMqttClient = new AWSIotMqttClient(clientEndpoint, clientId, awsAccessKeyId, awsSecretAccessKey);
		final AWSIotDevice device = new AWSIotDevice("MyLightBulb");

		try {
			awsIotMqttClient.attach(device);
			awsIotMqttClient.connect(5000L);
		} catch (AWSIotException | AWSIotTimeoutException e) {
			e.printStackTrace();
		}
		final ReactiveDeviceClient reactiveDeviceClient = new ReactiveDeviceClient(awsIotMqttClient);

		final Observable<String> lightBulbUpdates = reactiveDeviceClient
				.subscribe("$aws/things/MyLightBulb/shadow/update/accepted")
				.map(data -> "data: " + data + "\n\n")
				.concatWith(Observable.just("event: stop\ndata:\n\n"))
				.doOnNext(logger::debug);

		HttpServer.newServer(8070).start((req, resp) -> {
			logger.debug("Handling incoming request: ", req.getUri());
			switch (req.getUri()) {
				case "/":
					return resp
							.setHeader("Access-Control-Allow-Origin", "*")
							.setHeader("Content-Type", "text/event-stream")
							.writeStringAndFlushOnEach(lightBulbUpdates);
				case "/status":
					try {
						return resp
								.setHeader("Access-Control-Allow-Origin", "*")
								.setHeader("Content-Type", "application/json")
								.writeString(Observable.just(device.get()));
					} catch (AWSIotException e) {
						e.printStackTrace();
					}
				default:
					return resp.setStatus(HttpResponseStatus.NOT_FOUND);
			}
		}).awaitShutdown();
	}

}