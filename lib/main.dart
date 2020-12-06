import 'dart:async' show Future;
import 'dart:convert' show jsonDecode;

import 'package:consent_app/globals.dart' as globals;
import 'package:consent_app/style.dart';
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
import 'package:url_launcher/url_launcher.dart';

import 'iconMap.dart'; // Static class with icon lookup by string label
import 'item.dart'; // Item class definition
import 'process_document.dart'; // Function to process the Markdown document

///////////////////////////////////////////
//
// loadConfigFile
//
///////////////////////////////////////////
Future<Map> loadConfigFile() async {
  String configuration = await rootBundle.loadString('assets/config.json');
  return jsonDecode(configuration);
}

int totalSections = 0;

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
Future<List<Item>> loadAndProcessConsentDocument() async {
  //final consentDocument = 'hello.md';
  final consentDocument = 'consent.md';
  //print("==> loadConsentDocAsset():1: calling rootBundle.loadString");
  final data = await rootBundle.loadString('assets/$consentDocument');
  //print("==> loadConsentDocAsset():2: got data from rootBundle");
  //print('DATA SAMPLE: ${data.substring(0,50)}');
  return processDocument(data);
}

////////////////////////////////////
//
// main()
//
////////////////////////////////////
main() {
  // Now we are good to run the app:
  runApp(MyApp());
}

////////////////////////////////////////
//
// MyApp
//
////////////////////////////////////////
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List data = [];

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
    List<Item> consentData = await loadAndProcessConsentDocument();

    if (consentData.length > 0) {
      // DEBUG:
      print(globals.consent_url);
      print(globals.decline_url);

      // DEBUG: print sections:
      for (int i = 0; i < consentData.length; i++) {
        print('\n===== SECTION ${consentData[i].index} =====');
        print('TITLE   : ${consentData[i].title}');
        print('SUMMARY : ${consentData[i].summary}');
        print('DETAIL  : ${consentData[i].detail}');
        print('ICONNAME: ${consentData[i].iconName}');
      }

      // All document sections (i.e., Flutter route pages) are
      // created in advance:
      List<DocSection> allSections = List<DocSection>(consentData.length);
      totalSections = allSections.length;
      for (int i = 0; i < consentData.length; i++) {
        allSections[i] = DocSection(data: consentData[i]);
      }

      // Add a reference to the "next" section to each section,
      // (except for the very last section):
      for (int i = 0; i < allSections.length - 1; i++) {
        allSections[i].setNext(allSections[i + 1]);
      }
      // Finally, we *MUST* specify a subsequent route after we
      // are all done with the document sections
      // (Router builders should never return null).
      //
      // NOTA BENE: In this "template app", we will simply cycle
      // back to the home page. However, in any real app that
      // you derive from this template, be sure to point to a
      // consent agreement page or to another route representing
      // the beginning of the main functional part of your app:
      //
      allSections[allSections.length - 1].setNext(allSections[0]);

      setState(() {
        this.data = allSections;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.data.length > 0) {
      return MaterialApp(
        title: 'ManageHF Web',
        home: this.data[0],
        theme: primaryThemeData,
      );
    } else {
      return MaterialApp(
        title: 'ManageHF Web',
        home: Center(
          child: Container(
            width: 50,
            height: 50,
            child: Icon(Icons.access_time, size: 40.0),
          ),
        ),
        theme: primaryThemeData,
      );
    }
  }
}

//
// DocSection
//
//ignore: must_be_immutable
class DocSection extends StatefulWidget {
  final Item data;
  DocSection next;

  // Constructor
  DocSection({Key key, this.data}) : super(key: key);

  // setNext(nextSection)
  setNext(nextSection) {
    this.next = nextSection;
  }

  // hasNext()
  hasNext() {
    return this.next != null;
  }

  // getNext()
  getNext() {
    return this.next;
  }

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
    // In order to stop going crazy with highly-nested flutter code nonsense,
    // here we instantiate a few things in the way we want them to appear.
    // This makes the subsequent code a lot easier to follow:

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
        data: widget.data.summary,
      ),
    );

    /////////////////////////////////////////////////////
    //
    // detailTextWidget: This is the Markdown widget:
    //
    /////////////////////////////////////////////////////
    Widget detailTextWidget = Padding(
      padding: EdgeInsets.fromLTRB(52.0, 0.0, 52.0, 20.0),
      child: MarkdownBody(
          data: widget.data.detail),
    );

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
      if (widget.data.detail.isEmpty) {
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

    /////////////////////////////////////////////////////////
    //
    // conditionalBackButton: We don't want to show
    // a "< Back" button if there is nothing left
    // on the Navigator stack, hence this:
    //
    /////////////////////////////////////////////////////////
    Widget setBackButton() {
      if (Navigator.canPop(context)) {
        return ElevatedButton(
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
              Navigator.pop(context);
            });
      } else {
        // In order to avoid null children, Flutter recommends this:
        return SizedBox.shrink();
      }
    }

    // ... And here we store a reference to the materialized widget:
    // Widget conditionalBackButton = setBackButton();

    /////////////////////////////
    //
    // userConsents
    //
    /////////////////////////////
    userConsents() async {
      String hasConsentedUrl = globals.consent_url;
      if (await canLaunch(hasConsentedUrl)) {
        await launch(hasConsentedUrl);
      } else {
        throw 'Could not launch $hasConsentedUrl';
      }
    }

    ////////////////////////////////////////
    //
    // userDeclines():
    // What to do if user declines ...
    //
    ////////////////////////////////////////
    userDeclines() async {
      String hasDeclinedUrl = globals.decline_url;
      if (await canLaunch(hasDeclinedUrl)) {
        await launch(hasDeclinedUrl);
      } else {
        throw 'Could not launch $hasDeclinedUrl';
      }
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
                child: Text(
                  'Next',
                  style: TextStyle(
                      ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    // getNext() returns the next page route:
                    MaterialPageRoute(builder: (context) => widget.getNext()),
                  );
                },
              ),
            ),
          ],
        );
      }
    }

    // ... Here we store a reference to the materialized widget:
    // Widget conditionalNextButton = setNextButton();

    //
    // Now we can easily build out the rest of the layout:
    //
    return MaterialApp(
      title: "ManageHF Web",
      theme: primaryThemeData,
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          leading: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image(
              image: AssetImage('assets/managehftm_heart_ondark.png'),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Consent (${widget.data.index} of ${totalSections})',
              style: appBarTextStyle,
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 25.0, right: 25.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // ICON:
                Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 50.0, left: 0.0, right: 0.0),
                  // Icon is chosen based on the section title:
                  child: Icon(IconMap.lookup(widget.data.title), size: 48, color: primaryColor),
                ),
                // TITLE of the section:
                Padding(
                  padding: EdgeInsets.only(top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100.0, maxWidth: 600.0),
                    child: Text(
                      widget.data.title,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      maxLines: 5,
                      style: TextStyle(fontWeight: FontWeight.normal, color: primaryColor),
                      textScaleFactor: 2.0,
                    ),
                  ),
                ),
                // EXPANSION SECTION containing the section text elements:
                Padding(
                  padding: EdgeInsets.only(top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 100.0, maxWidth: 600.0),
                      child: formattedDocumentSection()),
                ),
                // CONDITIONAL NEXT BUTTON SECTION:
                Padding(
                  padding: EdgeInsets.only(top: 0.0, bottom: 50.0, left: 0.0, right: 0.0),
                  child: setNextButton(),
                ),
              ],
            ),
          ),
        ),
        // BOTTOM APP BAR conditionally holds the "back" button:
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50.0,
            child: Row(children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12.0),
                child: setBackButton(),
              ) // end container
            ]), // end of Row container
          ),
          color: footerBackgroundColor,
        ), // bottomNavigationBar
      ), // end Scaffold
    ); // end MaterialApp
  }
}
