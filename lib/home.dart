import 'dart:async';
import 'package:call_blocker/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'navigation/navigation_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Size? _size;
  late final Uuid _uuid;
  String? _currentUuid;
  String textEvents = "";
  int _counter = 0;
  late CallKitParams params;

  @override
  void initState() {
    super.initState();
    _uuid = const Uuid();
    _currentUuid = '';
    textEvents = '';
    initCurrentCall();
    listenerEvent(onEvent);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        backgroundColor: Colors.blueGrey[300],
        actions: [
          IconButton(
              onPressed: makeFakeCallInComing,
              icon: const Icon(
                Icons.call,
                color: Colors.white,
              )),
          IconButton(
              onPressed: endCurrentCall,
              icon: const Icon(
                Icons.call_end,
                color: Colors.white,
              )),
          IconButton(
              onPressed: startOutGoingCall,
              icon: const Icon(
                Icons.call_made,
                color: Colors.white,
              )),
          IconButton(
              onPressed: activeCalls,
              icon: const Icon(
                Icons.call_merge,
                color: Colors.white,
              )),
          IconButton(
              onPressed: endAllCalls,
              icon: const Icon(
                Icons.clear_all_sharp,
                color: Colors.white,
              )),
        ],
      ),
      body: _buildMainPageBody(),
    );
  }

  Widget _buildMainPageBody() {
    return LayoutBuilder(builder: (context, viewPortConstraints) {
      if (textEvents.isNotEmpty) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewPortConstraints.maxHeight),
            child: Text(textEvents),
          ),
        );
      } else {
        return const Center(child: Text('No Event'));
      }
    });
  }

  initCurrentCall() async {
    //check current calls from push kit
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('Data: $calls');
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {
        _currentUuid = '';
        return null;
      }
    }
  }

  Future<void> makeFakeCallInComing() async {
    await Future.delayed(const Duration(seconds: 3), () async {
      _currentUuid = _uuid.v4();
      print('the current: $_currentUuid - $_counter');
      _counter++;
      params = CallKitParams(
        id: _currentUuid,
        nameCaller: 'Zabre Kaletsha',
        appName: 'Callkit',
        avatar: 'https://i.pravatar.cc/100',
        handle: '0123456789',
        type: 0,
        duration: 30000,
        textAccept: 'Accept',
        textDecline: 'Decline',
        textMissedCall: 'Missed call',
        textCallback: 'Call back',
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: true,
          isShowCallback: true,
          isShowMissedCallNotification: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: 'assets/test.png',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: 'Incoming Call',
          missedCallNotificationChannelName: 'Missed Call',
        ),
        ios: IOSParams(
          iconName: 'CallKitLogo',
          handleType: '',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    });
  }

  //will end the current call
  Future<void> endCurrentCall() async {
    initCurrentCall();

    await FlutterCallkitIncoming.endCall(_currentUuid!);
  }

  //will start an outgoing call
  Future<void> startOutGoingCall() async {
    _currentUuid = _uuid.v4();
    final params = CallKitParams(
        id: _currentUuid,
        nameCaller: 'Zabre Kaletsha',
        handle: '01234678',
        type: 1,
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        ios: IOSParams(handleType: 'number'));

    await FlutterCallkitIncoming.startCall(params);
  }

  //check current active calls
  Future<void> activeCalls() async {
    var calls = await FlutterCallkitIncoming.activeCalls();
    print(calls);
  }

  //will end all calls
  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  //Get the device push token
  Future<void> getDevicePushTokenVoIP() async {
    var devicePushTokenVoIP =
        await FlutterCallkitIncoming.getDevicePushTokenVoIP();

    print('the device Token: $devicePushTokenVoIP');
  }

  //Listen to the current events
  Future<void> listenerEvent(Function? callBack) async {
    try {
      FlutterCallkitIncoming.onEvent.listen((event) async {
        print('the Event: $event');
        switch (event!.event) {
          case Event.ACTION_CALL_INCOMING:
            print(
                'An incoming call: ${event.body['number']} -${event.body['number'].runtimeType}');

            if (event.body['number'] == '0123456789') {
              await endAllCalls();
              await FlutterCallkitIncoming.endCall(_currentUuid!);
            }
            break;
          case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
            // TODO: Handle this case.
            break;
          case Event.ACTION_CALL_START:
            print('Started new call: ${event.body}');
            break;
          case Event.ACTION_CALL_ACCEPT:
            print('Accepted call: ${event.body}');
            NavigationService.instance
                .pushNamedIfNotCurrent(AppRoute.callingPage, args: event.body);
            break;
          case Event.ACTION_CALL_DECLINE:
            print('Declined call: ${event.body}');
            await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
            break;
          case Event.ACTION_CALL_ENDED:
            print('Ended Call: ${event.body}');
            break;
          case Event.ACTION_CALL_TIMEOUT:
            print('Call timedout: ${event.body}');
            break;
          case Event.ACTION_CALL_CALLBACK:
            print('Call back: ${event.body}');
            break;
          case Event.ACTION_CALL_TOGGLE_HOLD:
            print('Call hold: ${event.body}');
            break;
          case Event.ACTION_CALL_TOGGLE_MUTE:
            print('Call Mute: ${event.body}');
            break;
          case Event.ACTION_CALL_TOGGLE_DMTF:
            print('Call DMTF: ${event.body}');
            break;
          case Event.ACTION_CALL_TOGGLE_GROUP:
            print('Call Group: ${event.body}');
            break;
          case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
            print('Audio Session: ${event.body}');
            break;
        }
        if (callBack != null) {
          callBack(event.toString());
        }
      });
    } on Exception {
      print('Error: could not listen to events');
    }
  }

  //check with https://webhook.site/#!/2748bc41-8599-4093-b8ad-93fd328f1cd2
  Future<void> requestHttp(content) async {
    get(Uri.parse(
        'https://webhook.site/2748bc41-8599-4093-b8ad-93fd328f1cd2?data=$content'));
  }

  onEvent(event) {
    if (!mounted) return;
    setState(() {
      textEvents += "${event.toString()}\n";
    });
  }
}
