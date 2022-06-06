part of flutter_mentions;

class OptionList extends StatelessWidget {
  OptionList({
    required this.data,
    required this.onTap,
    required this.suggestionListHeight,
    this.suggestionListWidth,
    this.suggestionBuilder,
    this.suggestionListDecoration,
  });

  final Widget Function(Map<String, dynamic>)? suggestionBuilder;

  final List<Map<String, dynamic>> data;

  final Function(Map<String, dynamic>) onTap;

  final double suggestionListHeight;
  final double? suggestionListWidth;

  final BoxDecoration? suggestionListDecoration;

  @override
  Widget build(BuildContext context) {
    return data.isNotEmpty
        ? Container(
            decoration:
                suggestionListDecoration ?? BoxDecoration(color: Colors.white),
            constraints: BoxConstraints(
              maxHeight: suggestionListHeight,
              maxWidth: suggestionListWidth ?? double.infinity,
              minHeight: 0,
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Text(
                    'Suggestion',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          onTap(data[index]);
                        },
                        child: suggestionBuilder != null
                            ? suggestionBuilder!(data[index])
                            : Container(
                                color: Colors.blue,
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  data[index]['display'],
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          )
        : Container();
  }
}
