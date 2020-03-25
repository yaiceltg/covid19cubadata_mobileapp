import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatefulWidget {
  InfoScreen({Key key}) : super(key: key);

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
 

  _openUrl(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informacion'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text('La aplicación fue desarrollada usando los datos de la fuente:'),
                subtitle: Text('https://covid19cubadata.github.io/'),
                onTap: (){
                  this._openUrl('https://covid19cubadata.github.io/');                
                },
              ),
              ListTile(
                title: Text('El código se encuentra publicado en:'),
                subtitle: Text('https://github.com/yaiceltg/covid19cubadata_mobileapp'),
                onTap: () {
                  this._openUrl('https://github.com/yaiceltg/covid19cubadata_mobileapp');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
