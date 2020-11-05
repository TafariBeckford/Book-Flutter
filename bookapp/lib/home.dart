import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
 
String text;
bool _isLoading = false;
 const apiKey='AIzaSyDdgBP0yRgK26WvYOhXvc93w8MGv0ABQ7o';

Future<List<Book>> fetchBook() async {
  var url='https://www.googleapis.com/books/v1/volumes?q=$text&$apiKey';
  var response = await http.get(url);

   var data = jsonDecode(response.body);
   
   List<Book> books= [];

   for (var item in data){
    Book book = new Book(item["volumeInfo"]["title"],
       item["volumeInfo"]["authors"],
       item["volumeInfo"]["publishedDate"],
       item["volumeInfo"]["imageLinks"]["smallThumbnail"]
    );
     books.add(book);
}
   return books;
}

class Book {
  final String title; 
  final String authors;
  final int publishedDate; 
  final String thumbnail;
  
  Book(this.title, this.authors, this.thumbnail,this.publishedDate);
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text('Book')
      ),
       body: Container(
        child: FutureBuilder(
          future:fetchBook(),
          builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index){
                   return Container(
                    child: Card(
                      child: new Padding(
                          padding: new EdgeInsets.all(8.0),
                          child: new Row(
                            children: <Widget>[
                             snapshot.data[index].url != null? new Image.network(snapshot.data[index].thumbnail): new Container(),
                              new Flexible(
                                child: new Text(snapshot.data[index].title, maxLines: 10),
                              ),
                            ],
                          )
                      )
                  )
                   );
                }
                  );
              }else{
                return Container(
                  child: Text('Data Loading')
                );
              }  
          },
        ),

       ),
    );
  }
}