import 'dart:async' show Future;

import 'package:consent_app/src/style.dart';
import 'package:flutter/material.dart';
//////////////////////////////////////////////////////////////////////////
//
// consent app
//
// (c) 2020 by the Regents of the University of Michigan
//
// Written by Ed Trager <ehtrager@med.umich.edu>,<ed.trager@gmail.com>
// for Michael Dorsch's lab (https://pharmacy.umich.edu/dorsch-lab)
// at the College of Pharmacy
//
// First release: 2020.11.18.ET
//
//////////////////////////////////////////////////////////////////////////
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart'; // provides markdown support

import 'src/globals.dart';
import 'src/iconMap.dart'; // Static class with icon lookup by string label
import 'src/item.dart'; // Item class definition
import 'src/process_document.dart'; // Function to process the Markdown document

///////////////////////////////////////////////////////
//
// A place to store global configuration information:
//
///////////////////////////////////////////////////////
// Map globals;

//////////////////////////////////////////
//
// loadAndProcessConsentDocument()
//
//////////////////////////////////////////
Future<List<Item>> loadAndProcessConsentDocument(
    String pathToConsentDocument) async {
  final data = await rootBundle.loadString(pathToConsentDocument);
  //print("==> loadConsentDocAsset():2: got data from rootBundle");
  //print('DATA SAMPLE: ${data.substring(0,50)}');
  return processDocument(data);
}

late String _pathToConsentDocument;
late VoidCallback _onAccept;

////////////////////////////////////////
//
// MyApp
//
////////////////////////////////////////
class ConsentApp extends StatefulWidget {
  final String pathToConsentDocument;
  final VoidCallback onAccept;

  ConsentApp({Key? key, String? pathToConsentDocument, VoidCallback? onAccept})
      : assert(pathToConsentDocument != null || _pathToConsentDocument != null),
        assert(onAccept != null || _onAccept != null),
        this.pathToConsentDocument =
            pathToConsentDocument ?? _pathToConsentDocument,
        this.onAccept = onAccept ?? _onAccept,
        super(key: key);

  @override
  ConsentAppState createState() => ConsentAppState();

  static initialize(
      {required String pathToConsentDocument, required VoidCallback onAccept}) {
    _pathToConsentDocument = pathToConsentDocument;
    _onAccept = onAccept;
  }
}

class ConsentAppState extends State<ConsentApp> {
  List data = [];
  int totalSections = 0;
  int currentSection = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    // This next line is required, otherwise nothing appears:
    WidgetsFlutterBinding.ensureInitialized();
    // Asynchronously load the consent document
    // and parse it into sections:
    List<Item> consentData =
        await loadAndProcessConsentDocument(widget.pathToConsentDocument);

    if (consentData.length > 0) {
      // DEBUG: print sections:
      // for (int i = 0; i < consentData.length; i++) {
      //   print('\n===== SECTION ${consentData[i].index} =====');
      //   print('TITLE   : ${consentData[i].title}');
      //   print('SUMMARY : ${consentData[i].summary}');
      //   print('DETAIL  : ${consentData[i].detail}');
      //   print('ICONNAME: ${consentData[i].iconName}');
      // }

      final allSections = List.from(consentData);
      totalSections = consentData.length;

      setState(() {
        this.data = allSections;
      });
    }
  }

  void onNext() {
    if (currentSection < totalSections - 1) {
      setState(() {
        currentSection++;
      });
    }
  }

  void onAccept() {
    widget.onAccept();
  }

  void onBack() {
    if (currentSection > 0) {
      setState(() {
        currentSection--;
      });
    }
  }

  void onDecline() {
    setState(() {
      currentSection = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.data.length > 0) {
      // return this.data[0];
      return Theme(
        data: primaryThemeData,
        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            leading: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(
                image: AssetImage('assets/managehftm_heart_ondark.png',
                    package: "consent_app"),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Consent (${currentSection + 1} of $totalSections)',
                style: appBarTextStyle,
              ),
            ),
          ),
          body: DocSection(data: data[currentSection]),
          // BOTTOM APP BAR conditionally holds the "back" button:
          bottomNavigationBar: BottomAppBar(
            child: Container(
              height: 50.0,
              child: Row(children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12.0),
                  child: _buildBackButton(),
                ) // end container
              ]), // end of Row container
            ),
            color: footerBackgroundColor,
          ), // bottomNavigationBar
        ),
      );
      return MaterialApp(
        home: this.data[0],
        theme: primaryThemeData,
      );
    } else {
      return Center(
        child: Container(
          width: 50,
          height: 50,
          child: Icon(Icons.access_time, size: 40.0),
        ),
      );
    }
  }

  /////////////////////////////////////////////////////////
  //
  // conditionalBackButton: We don't want to show
  // a "< Back" button if there is nothing left
  // on the Navigator stack, hence this:
  //
  /////////////////////////////////////////////////////////
  Widget _buildBackButton() {
    if (currentSection > 0) {
      return ElevatedButton(
          key: backButtonKey,
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios,
                size: 16.0,
              ),
              Text('Back'),
            ],
          ),
          onPressed: () {
            setState(() => currentSection--);
          });
    } else {
      // In order to avoid null children, Flutter recommends this:
      return SizedBox.shrink();
    }
  }
}

//
// DocSection
//
class DocSection extends StatefulWidget {
  final Item data;

  // Constructor
  DocSection({Key? key, required this.data}) : super(key: key);

  // The following is left over from the flutter example code:
  @override
  _DocSectionState createState() => _DocSectionState();
}

//
// _DocSectionState
//
class _DocSectionState extends State<DocSection> {
  // Build method will also rerun every time setState is called:
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ICON:
            Padding(
              padding: EdgeInsets.only(
                  top: 50.0, bottom: 50.0, left: 0.0, right: 0.0),
              // Icon is chosen based on the section title:
              child: Icon(IconMap.lookup(widget.data.title),
                  size: 48, color: primaryColor),
            ),
            // TITLE of the section:
            Padding(
              padding: EdgeInsets.only(
                  top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minWidth: 100.0, maxWidth: 600.0),
                child: Text(
                  widget.data.title ?? "",
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 5,
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: primaryColor),
                  textScaleFactor: 2.0,
                ),
              ),
            ),
            // EXPANSION SECTION containing the section text elements:
            Padding(
              padding: EdgeInsets.only(
                  top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
              child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 100.0, maxWidth: 600.0),
                  child: formattedDocumentSection()),
            ),
            // CONDITIONAL NEXT BUTTON SECTION:
            Padding(
              padding: EdgeInsets.only(
                  top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
              child: setNextButton(),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////
  //
  // formattedDocumentSection: A section of the document may
  // consist of just a single "summary" section; or it might
  // have both a "summary" and a "detail" section. If we don't
  // have a "detail" section, then we can just use the RichText
  // widget. However, if we have a "detail" section too, then
  // we want to use an expansionTile containing the "summary"
  // as the title part, and the "detail" will be revealed when
  // the expansionTile is tapped or clicked:
  //
  ////////////////////////////////////////////////////////////////
  Widget formattedDocumentSection() {
    // In order to make some of the subsequent code easier to follow,
    // we set up some of the pieces of the page route in the following:

    //////////////////////////////////////////////////
    //
    // summaryText: the RichText
    // widget used to display the summary text
    //
    //////////////////////////////////////////////////
    Widget summaryText = Container(
      child: MarkdownBody(
        data: widget.data.summary ?? "",
      ),
    );

    /////////////////////////////////////////////////////
    //
    // detailTextWidget: This is the Markdown widget:
    //
    /////////////////////////////////////////////////////
    Widget detailTextWidget = Padding(
      padding: EdgeInsets.fromLTRB(52.0, 0.0, 52.0, 20.0),
      child: MarkdownBody(data: widget.data.detail ?? ""),
    );
    if (widget.data.detail?.isEmpty == true) {
      return summaryText;
    } else {
      return ExpansionTile(
        title: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 50.0),
          child: summaryText,
        ),
        children: <Widget>[detailTextWidget],
        backgroundColor: Colors.grey[200],
      );
    }
  }

  // The reference to the materialized widget is stored here:
  // Widget formattedSection = formattedDocumentSection();

  // ... And here we store a reference to the materialized widget:
  // Widget conditionalBackButton = setBackButton();

  /////////////////////////////
  //
  // userConsents
  //
  /////////////////////////////
  userConsents() async {
    final state = context.findAncestorStateOfType<ConsentAppState>();
    state?.onAccept();
  }

  ////////////////////////////////////////
  //
  // userDeclines():
  // What to do if user declines ...
  //
  ////////////////////////////////////////
  userDeclines() async {
    final state = context.findAncestorStateOfType<ConsentAppState>();
    state?.onDecline();
  }

  //
  // Code to conditionally set up the next button:
  //
  Widget setNextButton() {
    if (widget.data.title == 'Authorization') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 150.0,
                maxWidth: 150.0,
                minHeight: 40.0,
              ),
              child: ElevatedButton(
                key: consentsButtonKey,
                child: Text('I agree'),
                onPressed: userConsents,
              ),
            ),
            SizedBox(height: 30), // Used as padding
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 150.0,
                maxWidth: 150.0,
                minHeight: 40.0,
              ),
              child: ElevatedButton(
                key: declineButtonKey,
                child: Text('I decline'),
                onPressed: userDeclines,
              ),
            ),
          ]),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 200.0,
              minHeight: 40.0,
            ),
            child: ElevatedButton(
              key: nextButtonKey,
              child: Text(
                'Next',
                style: TextStyle(),
              ),
              onPressed: () {
                final state =
                    context.findAncestorStateOfType<ConsentAppState>();
                state?.onNext();
              },
            ),
          ),
        ],
      );
    }
  }
}
