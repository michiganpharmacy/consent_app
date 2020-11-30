import 'item.dart';
import 'dart:convert';

////////////////////////
//
// processDocument
//
////////////////////////
List<Item> processDocument(document){

  LineSplitter ls     = LineSplitter();       // Initialize a line splitter  ...
  List<String> lines  = ls.convert(document); // ... to split doc into lines for special parsing
  List<Item> sections = List<Item>();         // Container to hold the converted data
  Item accumulator    = new Item();           // Single Item to accumulate across lines

  // "singleton" sgPattern matches some word or words with no embedded colons 
  // but that is terminated by a single colon. This detects headers with
  // presumably nested stuff following on subsequent lines:
  RegExp sgPattern = new RegExp(r'^([^\:]+\w)\s*:\s*$');

  // kvPattern matches some word or words followed by a colon and then some
  // word or words (which could also end in a colon, since that can occur).
  // This detects a "key" followed by a colon, then a "value" (where the
  // value is allowed to have a terminating colon):          
  RegExp kvPattern = new RegExp(r'^\s*(.+\w)\s*:\s*(.+:?)$');
  RegExp httpPattern = new RegExp(r'http://');  
  RegExp summaryPattern = new RegExp(r'^\s*(summary)\s*:\s*(.+:?)$'); 
  RegExp detailPattern  = new RegExp(r'^\s*(details?)\s*:\s*(.+:?)$'); 

  RegExp unorderedListPattern = new RegExp(r'^\s*-\s*(.+)\s*$');
  // Track if we are processing detail lines:
  bool processingDetail = false;

  for(int i=0;i<lines.length;i++){
    String line = lines[i];
    //if(line.contains(sgPattern) ){
    if(line.contains(sgPattern) && i+1<lines.length && lines[i+1].contains(summaryPattern)){
      
      // Singleton pattern line: This starts a new section
      // with "summary:" and "detail:" sections in subsequent lines:
      Iterable<RegExpMatch> sgMatches = sgPattern.allMatches(line);
      var sgMatch = sgMatches.elementAt(0);
      //print('=== Singleton match on line no. $i ===');
      //print('${sgMatch.group(0)}');       
      //print('${sgMatch.group(1)}');       
      // So the only part we can store currently is the title
      // and we expect summary in the next line:
      processingDetail = false;
      // Beginning a new entry, so push accumulated to sections list:
      if(accumulator.title != '' ){
        sections.add(accumulator.clone());
      }
      accumulator.reset();
      accumulator.title    = sgMatch.group(1);
      accumulator.index    = sections.length+1;
      
    }else if(line.contains(kvPattern) && !line.contains(httpPattern)){
      // key-value pattern line has two possibilities:
      // (1) If the key is either "summary:" or "detail", then
      // this line is a continuation of a new section started 
      // with a singleton entry.
      // (2) Otherwise, this line is in fact the start of a new
      // section itself.
      
      Iterable<RegExpMatch> kvMatches = kvPattern.allMatches(line);
      // List<String> kv = matches.toList();
      //
      var kvMatch = kvMatches.elementAt(0); // => extract the first (and only) match
      //print('=== key-value pair match on line no. ${i} ===');
      //print("    ${kvMatch.group(1)}");       
      //print("    ${kvMatch.group(2)}"); 
      if(summaryPattern.hasMatch(line)){ 
      //if(kvMatch.group(1)=='summary'){
         processingDetail = false;
         //accumulator.reset();
         accumulator.summary  = kvMatch.group(2);
      
      }else if(detailPattern.hasMatch(line)){
      //}else if(kvMatch.group(1)=='detail'){
         processingDetail = true;
         //accumulator.reset();
         accumulator.detail = kvMatch.group(2);

      }else{
         // Generic complete case which only has a summary and no detail:
         processingDetail = false;
      
         // Beginning a new entry, so push accumulated to sections list:
         if(accumulator.title != '' ){
           sections.add(accumulator.clone());
         }

         accumulator.reset();
         accumulator.title    = kvMatch.group(1);
         accumulator.summary  = kvMatch.group(2);
         accumulator.index    = sections.length+1;
      }                    
    }else{
      // We get here if line does not match sgPattern or kvPattern.
      // In general, these are CONTINUATION LINES. We append these
      // to either the summary or the detail section, depending on
      // the "processingDetail" flag:
      if(processingDetail){
        // Processing detail section is the most complicated, because
        // we allow multiple paragraphs and unordered lists:
        if( line.isEmpty){
          // Just add (up to two) newlines (to indicate to the markdown processor
          // the end of a paragraph) and we're done:
          if(accumulator.detail.endsWith('\n')){
            accumulator.detail += '\n';
          }else{
            accumulator.detail += '\n\n';
          }
        }else{
          // Not empty:
          if(unorderedListPattern.hasMatch(line)){
            // Unordered list:
            if(!accumulator.detail.endsWith('\n')){
              accumulator.detail += '\n';
            }
            Iterable<RegExpMatch> ulMatches = unorderedListPattern.allMatches(line);
            var ulMatch = ulMatches.elementAt(0); // => extract the first (and only) match
            accumulator.detail += '- ';           // => Markdown unordered list tag
            accumulator.detail += ulMatch.group(1);
          }else{
            // Continuation line from a paragraph
            // or possibly a new paragraph
            if( ! accumulator.detail.endsWith(' ')
                && ! accumulator.detail.endsWith('\n')
                && line.isNotEmpty
                && line[0] != ' ' 
            ){
              // add space so words don't get smushed:
              accumulator.detail += ' ';
            }
            accumulator.detail += line;
          }
        } 
        //
      }else{
        // Get here if we are processing summary lines:
        // add a space if needed before appending line:
        if( accumulator.summary.isNotEmpty 
            && ! accumulator.summary.endsWith(' ')
            && line.isNotEmpty
            && line[0] != ' '
        ){
            accumulator.summary += ' ';
        } 
        accumulator.summary += line;
      }
    }
  }
  // Push the very last accumulated 
  // entry into sections list:
  if(accumulator.title != '' ){
     sections.add(accumulator.clone());
  }

  // DEBUG: print sections:
  //for(int i=0;i<sections.length;i++){
  //  print('\n== SECTION ${i+1} ===============');
  //  print('TITLE: ${sections[i].title}'    );
  //  print('SUMMARY: ${sections[i].summary}');
  //  print('DETAIL: ${sections[i].detail}'  );
  //}
  
  return sections;

}
// end of processDocument

