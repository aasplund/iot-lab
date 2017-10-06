package se.gunnebo.iot;

import com.amazonaws.services.iot.client.AWSIotException;
import com.amazonaws.services.iot.client.AWSIotMessage;
import com.amazonaws.services.iot.client.AWSIotMqttClient;
import com.amazonaws.services.iot.client.AWSIotTopic;
import rx.Emitter;
import rx.Observable;

public class ReactiveDeviceClient {
	private AWSIotMqttClient client;

	public ReactiveDeviceClient(AWSIotMqttClient client) {
		this.client = client;
	}

	public Observable<String> subscribe(String topic) {

		return Observable.create(sink -> {
			try {
				client.subscribe(new AWSIotTopic(topic){
					@Override
					public void onMessage(AWSIotMessage message) {
						sink.onNext(message.getStringPayload());
					}
				});
			} catch (AWSIotException e) {
				sink.onError(e);
			}
		}, Emitter.BackpressureMode.NONE);

	}
}
