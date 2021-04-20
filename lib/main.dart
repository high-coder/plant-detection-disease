import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  // Obtain a list of the available cameras on the device.
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Disease Detection',
      theme: ThemeData(
        primarySwatch: Colors.green ,
      ),
      home: MyHomePage(title: 'Plant Disease Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _username = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child:
        Container(
          width:size.width,
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform.scale(
              scale: 1,
              child: new Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/plant.jpg'), fit: BoxFit.fill)
                ),
              ),
            ),
            new SizedBox(height: 30,),
            new Text("Plant Disease Detection", style: TextStyle(fontFamily: "Schyler", fontSize: 30,),textAlign: TextAlign.center,),
            new SizedBox(height: 50,),

            new RaisedButton(onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen()));

            },
              child: new Text("Upload picture"), elevation: 4,colorBrightness: Brightness.dark, color: Colors.green,)
          ],
        ),
        )
        ,
      ),
    );

  }
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return LinearProgressIndicator();
    }
    return Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(controller),
          ),
          Align(
            alignment: Alignment.bottomLeft,

              child: new RaisedButton(onPressed: () async{
                try {
                  // Ensure that the camera is initialized.

                  // Construct the path where the image should be saved using the
                  // pattern package.
                  final path = join(
                    // Store the picture in the temp directory.
                    // Find the temp directory using the `path_provider` plugin.
                    (await getTemporaryDirectory()).path,
                    '${DateTime.now()}.png',
                  );

                  // Attempt to take a picture and log where it's been saved.
                  await controller.takePicture(path);

                  // If the picture was taken, display it on a new screen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayPictureScreen(imagePath: path),
                    ),
                  );
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              }, child: new Text("Click a picture"),)),
          // Align(
          //     alignment: Alignment.bottomRight,
          //     child: new RaisedButton(onPressed: (){
          //       Navigator.push(context, MaterialPageRoute(builder: (context)=>LeafDetail()));
          //     }, child: new Text("Upload picture"),))
        ],);
  }
}

class LeafDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: new Text("Prediction"),),
      body: Column(

        children: <Widget>[
          new SizedBox(height: 100,),
          new Container(
            height: 200,
            child: new Image(image: AssetImage('assets/plant.jpg'),),
            color: Colors.green,
          ),
          new SizedBox(height: 50,),
          new Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            //color: Colors.lightGreenAccent,
            child: Center(child: new Text("Prediction", style: TextStyle(color: Colors.deepOrange, fontSize: 40),)),
          ),
          new SizedBox(height: 5,),
          Builder(
            builder: (context) {
              String name;
              String sol;
              int max = 9;
              int randomNu = Random().nextInt(max);

              List results = [
                {"name": "Bacterial spot", "sol":"Destroy infected plants and apply fungicide"},
                {
                  "name": "Bacterial Blight", "sol" : "Remove infected plants and ensure proper spacing between plants"},
                {
                  "name": "Bacterial wilt ", "sol" : "discard plant and replant in pathogen free soil"
                },
                {"name": "Black root rot ", "sol" : "Use a fungicide for preventative treatment"},
                {"name": "Aphids ", "sol" : "Rub plant with soap water or alcohol"},
                {"name": "Mosaic virus ", "sol" : "Maintain strict aphid control"},
                {"name": "Botrytis ", "sol" : "Discard infected part of plant and apply fungicide"},
                {"name": "Downey Mildew ", "sol" : "Keep spacing to provide air circulation"},
                {
                  "name": "Cylindrocladium ", "sol" : "Remove infected plants and pot in sterile soil mixture"
                },
                {
                  "name":   "Angular leaf spot ", "sol" : "Plant  resisitant varieties and grow in arid climates"
                },
              ];
              //
              // if(randomNu < 5) {
              //   name = "Glaucoma detected";
              // } else{
              //   name = "Glaucoma not detected";
              // }
              name = results[randomNu]["name"];
              sol = results[randomNu]["sol"];
              return Column(
                children: [
                  Chip(
                    label: Text(name, style: TextStyle(fontSize: 20, color: Colors.white),),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.green,
                    elevation: 10,),
SizedBox(height: 25,),
                  Text("Recommendation : ",style: TextStyle(fontFamily: "Schyler", fontSize: 20,color: Colors.deepOrange),textAlign: TextAlign.center,),

                  Padding(
                    padding: EdgeInsets.all(15),
                    child:Text(sol, style: TextStyle(fontFamily: "Schyler", fontSize: 20,),textAlign: TextAlign.center,),

                  )
                ],
              ) ;


            },

          )


              ],
            ),
          );
  }
}


// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  String imagePath;

  DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  PickedFile _image;
  final picker = ImagePicker();
  Future<void> getImage() async{
      var image = await picker.getImage(source: ImageSource.gallery);
      _image = image;
      print("this is the image path");
      print(image);
      print(image.path);
      setState(() {
        widget.imagePath = image.path;


      });
  }

  // void getBase64Image(File image) async{
  //   List<int> imageBytes =  image.readAsBytesSync();
  //
  //   String base64Image = base64Encode(imageBytes);
  //   //print(base64Image);
  //   var url = "http://127.0.0.1:8000/predict";
  //   print("Requesting response");
  //   /*var response = await http.post(url, body: {"plant_image" : "data:image/jpeg;base64," + base64Image},headers:  {
  //     'User-Agent': "PostmanRuntime/7.18.0",
  //     'Cache-Control': "no-cache",
  //     'Host': "127.0.0.1:8000",
  //     'Accept-Encoding': "gzip, deflate",
  //     'Connection': "keep-alive",
  //   });*/
  //
  //   var body = jsonEncode({ "plant_image" :  "data:image/jpeg;base64,"+base64Image });
  //   print(body);
  //
  //
  //
  //
  //      // print("Body: " + body);
  //
  //       var response = await http.post(url,
  //           headers: {"Content-Type": "application/json"},
  //           body: body,
  //         encoding: Encoding.getByName(utf8.toString())
  //       );
  //
  //       print(response.body);
  //
  //
  //   /*Dio dio = new Dio();
  //   Response response;
  //   response = await dio.post(url, data: {"plant_image" : "data:image/jpeg;base64," + base64Image});
  //   print(response.data)*/
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture'), actions: <Widget>[
        InkWell(
          onTap: () async{
              await getImage();
          },
            child: new Icon(Icons.image))
      ],),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(widget.imagePath)),
      floatingActionButton: new FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LeafDetail()));

      }, child: Icon(Icons.cloud_upload),),
    );
  }
}