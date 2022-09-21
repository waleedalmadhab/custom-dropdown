part of 'custom_dropdown.dart';

const _headerPadding = EdgeInsets.only(
  left: 16.0,
  top: 16,
  bottom: 16,
  right: 14,
);
const _overlayOuterPadding = EdgeInsets.only(bottom: 12, left: 12, right: 12);
const _overlayShadowOffset = Offset(0, 6);
const _listItemPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);

class _DropdownOverlay extends StatefulWidget {
  final List<Item> items;

  final TextEditingController controller;
  final Size size;
  final LayerLink layerLink;
  final VoidCallback hideOverlay;
  final String hintText;
  final TextStyle? headerStyle;
  final TextStyle? listItemStyle;
  final bool? excludeSelected;
  final bool? canCloseOutsideBounds;
  final _SearchType? searchType;
  final Color? searchColor;
  final String? searchHint;
  final TextStyle? hintStyle;
  final Function(Item)? onItemSelect;


  const _DropdownOverlay({
    Key? key,
    required this.items,
    required this.controller,
    required this.size,
    required this.layerLink,
    required this.hideOverlay,
    required this.hintText,
    this.headerStyle,
    this.onItemSelect,
    this.listItemStyle,
    this.excludeSelected,
    this.canCloseOutsideBounds,
    this.searchType,
    this.searchHint='search',this.searchColor=Colors.grey,

    this.hintStyle
  }) : super(key: key);

  @override
  _DropdownOverlayState createState() => _DropdownOverlayState();
}

class _DropdownOverlayState extends State<_DropdownOverlay> {
  bool displayOverly = true;
  bool displayOverlayBottom = true;
  late String headerText;
  late List<Item> items;
  late List<Item> filteredItems;
  final key1 = GlobalKey(), key2 = GlobalKey();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final render1 = key1.currentContext?.findRenderObject() as RenderBox;
      final render2 = key2.currentContext?.findRenderObject() as RenderBox;
      final screenHeight = MediaQuery.of(context).size.height;
      double y = render1.localToGlobal(Offset.zero).dy;
      if (screenHeight - y < render2.size.height) {
        displayOverlayBottom = false;
        setState(() {});
      }
    });

    headerText = widget.controller.text;
    if (widget.excludeSelected! &&
        widget.items.length > 1 &&
        widget.controller.text.isNotEmpty) {
      items = widget.items.where((item) => item != headerText).toList();
    } else {
      items = widget.items;
    }
    filteredItems = items;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // search availability check
    final onListDataSearch = widget.searchType == _SearchType.onListData;

    // border radius
    final borderRadius = BorderRadius.circular(12);

    // overlay icon
    final overlayIcon = Icon(
      displayOverlayBottom
          ? Icons.keyboard_arrow_up_rounded
          : Icons.keyboard_arrow_down_rounded,
      color: widget.searchColor!,
      size: 20,
    );

    // overlay offset
    final overlayOffset = Offset(-12, displayOverlayBottom ? 0 : 60);

    // list padding
    final listPadding =
        onListDataSearch ? const EdgeInsets.only(top: 8) : EdgeInsets.zero;

    // items list
    final list = items.isNotEmpty
        ? _ItemsList(
            scrollController: scrollController,
            excludeSelected:
                widget.items.length > 1 ? widget.excludeSelected! : false,
            items: items,
            padding: listPadding,
            headerText: headerText,
            itemTextStyle: widget.listItemStyle,
            onItemSelect: (value) {
              widget.onItemSelect!(value);
              if (headerText != value.name) {
                widget.controller.text = value.name;
              }
              setState(() => displayOverly = false);
            },
          )
        : const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'No result found.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );

    final child = Stack(
      children: [
        Positioned(
          width: widget.size.width + 24,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            followerAnchor:
                displayOverlayBottom ? Alignment.topLeft : Alignment.bottomLeft,
            showWhenUnlinked: false,
            offset: overlayOffset,
            child: Container(
              key: key1,
              padding: _overlayOuterPadding,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24.0,
                      color: Colors.black.withOpacity(.08),
                      offset: _overlayShadowOffset,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedSection(
                    animationDismissed: widget.hideOverlay,
                    expand: displayOverly,
                    axisAlignment: displayOverlayBottom ? 1.0 : -1.0,
                    child: SizedBox(
                      key: key2,
                      height: items.length > 4
                          ? onListDataSearch
                              ? 270
                              : 225
                          : null,
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return true;
                          },
                          child: Theme(
                            data: ThemeData(

                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: _headerPadding,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          headerText.isNotEmpty
                                              ? headerText
                                              : widget.hintText,
                                          style: widget.headerStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      overlayIcon,
                                    ],
                                  ),
                                ),
                                if (onListDataSearch)
                                  _SearchField(
                                    items: filteredItems,
                                    searchHint: widget.searchHint,
                                    searchColor: widget.searchColor,
                                    hintStyle: widget.hintStyle,
                                    onSearchedItems: (val) {
                                      setState(() => items = val);
                                    },
                                  ),
                                items.length > 4 ? Expanded(child: list) : list
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => setState(() => displayOverly = false),
      child: widget.canCloseOutsideBounds!
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
              child: child,
            )
          : child,
    );
  }
}

class _ItemsList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Item> items;
  final bool excludeSelected;
  final String headerText;
  final ValueSetter<Item> onItemSelect;
  final EdgeInsets padding;
  final TextStyle? itemTextStyle;

  const _ItemsList({
    Key? key,
    required this.scrollController,
    required this.items,
    required this.excludeSelected,
    required this.headerText,
    required this.onItemSelect,
    required this.padding,
    this.itemTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final listItemStyle = const TextStyle(
      fontSize: 16,
    ).merge(itemTextStyle);

    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        padding: padding,
        itemCount: items.length,
        itemBuilder: (_, index) {
          final selected = !excludeSelected && headerText == items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.grey[200],
              onTap: () => onItemSelect(items[index]),
              child: Container(
                color: selected ? Colors.grey[100] : Colors.transparent,
                padding: _listItemPadding,
                child: Text(
                  items[index].name,
                  style: listItemStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final List<Item> items;
  final String? searchHint;
  final Color? searchColor;
 final TextStyle? hintStyle;
  final ValueChanged<List<Item>> onSearchedItems;
  const _SearchField({
    Key? key,
    required this.items,
    required this.onSearchedItems,
    this.searchHint='search',
    this.searchColor=Colors.grey,
    this.hintStyle
  }) : super(key: key);

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final searchCtrl = TextEditingController();

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
   // WidgetsBinding.instance?.addPostFrameCallback((_) =>FocusScope.of(context).requestFocus(_focusNode));

    FocusManager.instance.primaryFocus?.requestFocus(_focusNode);

  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();

    searchCtrl.dispose();
    super.dispose();
  }

  void onSearch(String str) {
    final result = widget.items
        .where((item) => item.name.toLowerCase().contains(str.toLowerCase()))
        .toList();
    widget.onSearchedItems(result);
  }

  void onClear() {
    if (searchCtrl.text.isNotEmpty) {
      searchCtrl.clear();
      widget.onSearchedItems(widget.items);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: searchCtrl,
        onChanged: onSearch,
        autofocus: true,
        scrollPadding: EdgeInsets.only(bottom:300),
        focusNode: _focusNode,
        style: widget.hintStyle !=null ?widget.hintStyle:TextStyle(),
        decoration: InputDecoration(
          filled: true,

          fillColor: widget.searchColor!.withOpacity(.1),

          constraints: const BoxConstraints.tightFor(height: 40),

          contentPadding: const EdgeInsets.all(8),

          hintText: widget.searchHint,

          hintStyle:  widget.hintStyle !=null ?widget.hintStyle:TextStyle(),

          prefixIcon:  Icon(Icons.search, color:widget.searchColor!, size: 22),

          suffixIcon: GestureDetector(
            onTap: onClear,
            child:  Icon(Icons.close, color: widget.searchColor!, size: 20),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.searchColor!.withOpacity(.25),
              width: 1,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.searchColor!.withOpacity(.25),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.searchColor!.withOpacity(.25),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
