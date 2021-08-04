import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Search extends StatefulWidget {
  static const kIconColor =
      Color(0xff008542); //to be changed to apps primary color
  static const kNoSuggestionColor = Color(0xff737373);
  final List<String> suggestionList;
  final String hint; //tab name which is selected

  Search({required this.suggestionList, required this.hint});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late FocusNode _focusNode;
  late SpeechToText _speech;
  bool _isListening = false;
  bool _textFieldActive = false;
  String _text = '';
  var _textFieldController = TextEditingController();
  int queryCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(
            left: 10.0,
            top: 10.0,
            right:
                10.0), //remove this margin when integrating widget to project giving final widget
        child: Row(
          children: [
            Expanded(
                child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _textFieldController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefix: _textFieldActive
                            ? IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  print('arrow pressed');
                                  setState(() {
                                    _textFieldController.text = '';
                                    _textFieldActive = false;
                                  });
                                },
                              )
                            : IconButton(
                                icon: Icon(Icons.search),
                                color: Search.kIconColor,
                                onPressed: () {
                                  print('search pressed');
                                },
                              ),
                        suffix: queryCount > 0 && _isListening == false
                            ? IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  print('close pressed');
                                  setState(() {
                                    _textFieldController.text = '';
                                  });
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                    _isListening ? Icons.mic : Icons.mic_none),
                                color: Search.kIconColor,
                                onPressed: () {
                                  print('voice button pressed');
                                  checkPermissionToListen();
                                },
                              ),
                        border: InputBorder.none,
                        hintText: 'Search and add a ${widget.hint}',
                        hintStyle: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    suggestionsBoxDecoration:
                        SuggestionsBoxDecoration(color: Colors.white),
                    suggestionsCallback: (String query) {
                      setState(() {
                        queryCount = query.length;
                      });
                      if (queryCount > 0) {
                        _textFieldActive = true;
                        return widget.suggestionList.where((item) => item
                            .toString()
                            .toLowerCase()
                            .startsWith(query.toLowerCase()));
                      } else {
                        return [];
                      }
                    },
                    hideSuggestionsOnKeyboardHide: false,
                    hideOnLoading: true,
                    keepSuggestionsOnSuggestionSelected: false,
                    onSuggestionSelected: (suggestion) {
                      _textFieldController.text = suggestion.toString();
                      //take selected search result from here and accordingly show item in list.
                    },
                    itemBuilder: (BuildContext context, itemData) {
                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            left: 43.0, right: 15.0, top: 15.0, bottom: 15.0),
                        child: Text.rich(
                          TextSpan(
                            style:
                                TextStyle(color: Colors.black, fontSize: 14.0),
                            children: [
                              TextSpan(
                                text: itemData
                                    .toString()
                                    .toUpperCase()
                                    .substring(0, queryCount),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                  text: itemData
                                      .toString()
                                      .toUpperCase()
                                      .substring(queryCount,
                                          itemData.toString().length))
                            ],
                          ),
                        ),
                      );
                    },
                    noItemsFoundBuilder: (context) {
                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            left: 43.0, right: 15.0, top: 15.0, bottom: 15.0),
                        child: Text(
                          'No matches- try another name',
                          style: TextStyle(
                            color: Search.kNoSuggestionColor,
                          ),
                        ),
                      );
                    })),
          ],
        ));
  }

  void checkPermissionToListen() async {
    var microphoneStatus = await Permission.microphone.status;
    print(microphoneStatus);
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
      microphoneStatus = await Permission.microphone.status;
      print(Permission.microphone.status);
      if (microphoneStatus.isGranted) {
        _initSpeechToText();
      }
    } else {
      _initSpeechToText();
    }
  }

  void _initSpeechToText() {
    _speech = SpeechToText();
    _listen();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'listening') {
            _text = '';
          }
          if (val == 'notListening') {
            _isListening = false;
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            print(_text);
            _focusNode.requestFocus();
            _textFieldController.text = _text;
            _textFieldController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textFieldController.text.length));
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
    _focusNode.dispose();
  }
}
