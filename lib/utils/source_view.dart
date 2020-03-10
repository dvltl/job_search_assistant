class SourceView {
  static final String _separator = '|';
  final String _name;
  final String _link;

  SourceView._({name, link})
      : _name = name ?? "",
        _link = link ?? "";

  static SourceView fromString(String str) {
    String namePart, linkPart;

    if (str != null) {
      int linkPartStart = str.indexOf(_separator);
      namePart = str.substring(0, linkPartStart);
      linkPart = str.substring(linkPartStart + 1);
    }

    return SourceView._(name: namePart, link: linkPart);
  }

  static SourceView fromStrings(String name, String link) {
    return SourceView._(name: name, link: link);
  }

  String toString() {
    return this._name + SourceView._separator + this._link;
  }

  String getName() => _name;

  String getLink() => _link;
}
