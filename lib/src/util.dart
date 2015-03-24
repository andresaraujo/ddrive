import 'dart:math' as math;

prettySize(bytes) {
  if(bytes is String){
    bytes = num.parse(bytes);
  }
  var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  if (bytes == 0) return '0 Bytes';
  var i = (math.log(bytes) / math.log(1024)).floor();
  return "${(bytes / math.pow(1024, i)).round()} ${sizes[i]}";
}