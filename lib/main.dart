import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  final FlutterTts flutterTts = FlutterTts();
  final FlutterTts flutterTts2 = FlutterTts();
  final FlutterTts flutterTtsCustom = FlutterTts();

   MobileScannerController cameraController = MobileScannerController();

    /*
    
    Product Name: Airpods
    Product Description: asdasasdasdasdas

    Product Price: kideny
    
    */

    bool readDescription = false;

    Map<String?, String> data = {
      "name" : "Product name: Apple Airpods",
      "description" : "Product Description: They are a set of wireless earphones from Apple",
      "price" : "Product Price: 12000"
    };

    customSpeak(String text) async {
      print("Speaking ${text}");
      await flutterTtsCustom.awaitSpeakCompletion(true);
      await flutterTtsCustom.setLanguage("en-IN");
      await flutterTtsCustom.speak(text);
    }

    customSpeakPrice(String text) async {
      print("Speaking ${text}");
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage("en-IN");
      await flutterTts.speak("Product price : " + text);
    }

    createRequest(String text) async {
      var requestUrl = "https://yash-qr-code.herokuapp.com/api/products/" + text;
      var url = Uri.parse(requestUrl);
      var response = await http.get(url);
      print('Response Body : ${response.body}');
      print('Response Status Code: ${response.statusCode} ,${response.statusCode.runtimeType} ');
      // Map decoded = json.decode(response);


      if(response.statusCode == 200){
        var data = jsonDecode(response.body);
        print(data);
        print(data.runtimeType);

        var words;

        if(data.containsKey("isDirection")){
          // Direction
          words = data["directions"];
        }
        else{
            // Data is a product
          if(readDescription){
            words = data["name"] + "\n,Product Price " + data["price"].toString() + "\n,Product Description: " + data["description"];  
          }
          else{
          words = data["name"] + "\n,Product Price " + data["price"].toString();
          }
        }
        
        customSpeak(words as String);
        // customSpeakPrice(data["price"].toString());
      }

    }

    speak(String text) async {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage("en-IN");

      if(readDescription){
        await flutterTts.speak(data["name"] as String);
        // await flutterTts.speak(data["description"] as String);
        // await flutterTts.speak(data["price"] as String);
        await flutterTts.speak(data["price"] as String);
        await flutterTts2.speak(data["description"] as String);
      }
      else{
        await flutterTts.speak(data["name"] as String);
        await flutterTts.speak(data["price"] as String); 
      }
    }

    final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "TTS Test"
          ),
          centerTitle: true
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 200,
                width: 200,
                child: MobileScanner(
                  allowDuplicates: false,
                  controller: cameraController,
                  onDetect: (barcode, args) {
                    final String code = barcode.rawValue as String;
                    debugPrint(code);
                    createRequest(code);
                    // customSpeak(code);   
                  },
                )
              ),
              Padding(
                child: TextFormField(
                  controller: _textEditingController,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 100,
                        child: ElevatedButton(
                          onPressed: () => speak(_textEditingController.text),
                          
                          child: const Text("Press to Speak")
                          ),
                      ),
                    ),
                  ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 100,
                          child: ElevatedButton(
                            onPressed: ()  {
                              readDescription = !readDescription;
                              print("vibrate!!");
                              HapticFeedback.vibrate();
                              },
                            child: const Text("Toggle Description")
                            ),
                        ),
                      ),
                    ),
                ],
              )
            ]
          ),
        ),
      ),
    );
  }
}
