import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'book.dart';
import 'package:bookapp/Spinner.dart';

const apiKey='AIzaSyDdgBP0yRgK26WvYOhXvc93w8MGv0ABQ7o';

class BookApp extends StatefulWidget {
  BookApp({Key key}) : super(key: key);

  @override
  _BookAppState createState() => _BookAppState();
}

class _BookAppState extends State<BookApp> {

 List<BookClass> books = [];

  final subject = new PublishSubject<String>();

  bool loading = false;

  void _textChanged(String text) {
    if(text.isEmpty) {
      setState((){loading = false;});
      clearList();
      return;
    }
    setState((){loading = true;});
    clearList();
    
    http.get("https://www.googleapis.com/books/v1/volumes?q=$text&$apiKey")
        .then((response) => response.body)
        .then(json.decode)
        .then((map) => map["items"])
        .then((list) {list.forEach(updateBook);})
        .catchError(error)
        .then((e){setState((){loading = false;});});
  }
  void updateBook(book) {
    setState(() {
      books.add(BookClass(book["volumeInfo"]["title"],
       book["volumeInfo"]["imageLinks"]["smallThumbnail"],
      )
       );
    });
  }
  void error(d) {
    setState(() {
      loading = false;
    });
  }

  void clearList() {
    setState(() {
      books.clear();
    });
  }


  @override
  void initState() {
    super.initState();
    subject.stream.debounceTime(Duration(milliseconds:600)).listen(_textChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        title:  Text('Book App'),
      ),
      body: Container(
       
        padding:  EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
             TextFormField(
                
              decoration:  InputDecoration(
                labelText: "Enter Book",
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
),
              onChanged: (string) => (subject.add(string)),
            ),
            loading? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(child: loader),
            ) : new Container(),
             Expanded(
              child: ListView.builder(
                padding:  EdgeInsets.all(8.0),
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              books[index].url != null? Image.network(books[index].url): Container(),
                               Flexible(
                                child: Column(
                                  children: <Widget>[
                                    Text(books[index].title, maxLines: 10,
                                     style:TextStyle(color:Colors.black)
                                     ),
                                    //Text(books[index].publishedDate.toString(), maxLines: 10)
                                  ],
                                ),
                                
                              ),
                            ],
                          )
                      )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  