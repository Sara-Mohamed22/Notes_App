class DateTimeManager
{

  static String getTime(){
  var t  = DateTime.now() ;
    return '${t.day}-${t.month}-${t.year} ${t.hour}: ${t.minute}' ;

  }

}