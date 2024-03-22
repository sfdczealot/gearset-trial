public class CS_utl_Datetime {
    public static Datetime getTimezoneOffset(String inputDate) {
        Datetime outputDatetime = null;

        List<String> inputDateTime = inputDate.split(' ');
        List<String> dmy = inputDateTime[0].split('-');
        //PLS CHANGE START
        if (dmy.size() == 1) {
          dmy = inputDateTime[0].split('/');
        }
        //PLS CHANGE END
        List<String> hm = inputDateTime[1].split(':');
        //Calculate offset in hours

        Datetime outputDatetimeGmt = Datetime.newInstanceGmt(Integer.valueOf(dmy[0]), Integer.valueOf(dmy[1]), Integer.valueOf(dmy[2]), Integer.valueOf(hm[0]), Integer.valueOf(hm[1]), 0); // seconds are zeroed
        return outputDatetimeGmt.addSeconds(-getOffset(inputDate));
    }

    public static Integer getOffset(String inputDate) {
        List<String> inputDateTime = inputDate.split(' ');
        List<String> dmy = inputDateTime[0].split('-');
        //PLS CHANGE START
        if (dmy.size() == 1) {
          dmy = inputDateTime[0].split('/');
        }
        //PLS CHANGE END
        List<String> hm = inputDateTime[1].split(':');
        String timeZoneName = inputDateTime.size() > 2 ? inputDateTime[2] : UserInfo.getTimeZone().getID();

        Timezone tz = Timezone.getTimeZone(timeZoneName);
        Datetime dt = Datetime.newInstance(Integer.valueOf(dmy[0]), Integer.valueOf(dmy[1]), Integer.valueOf(dmy[2]), Integer.valueOf(hm[0]), Integer.valueOf(hm[1]), 0); // seconds are zeroed

        return tz.getOffset(dt) / (1000);
    }
}