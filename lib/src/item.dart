

//
// Item class
//
class Item {
  Item({
    this.title = '',
    this.summary = '',
    this.detail = '',
    this.expanded = false,
    this.index = 0,
    this.iconName = '',
  });

  String? title;
  String? summary;
  String? detail;
  bool? expanded;
  int? index;
  String? iconName;

  reset() {
    this.title = '';
    this.summary = '';
    this.detail = '';
    this.expanded = false;
    this.index = 0;
    this.iconName = '';
  }

  // 
  // clone:
  //
  clone(){
    return new Item(
        title:this.title,
        summary:this.summary,
        detail:this.detail,
        expanded:this.expanded,
        index:this.index,
        iconName:this.iconName,
    );
  }
  
}

