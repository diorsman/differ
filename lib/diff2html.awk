#!/usr/bin/env awk
    BEGIN {
        begin = 0
        first_c= 0
        second_c= 0

        print "<html>"
        print "<head>"
        print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
        print "<title>REPORT</title>"
        print "<style type=\"text/css\">" 
        print "body {font-family:Consolas, monospace, STXihei, \"华文细黑\", SimSun, \"宋体\", \"Microsoft YaHei\", \"微软雅黑\";}"
        print "h1 {text-align: center; color: blue}"
        print "table {width: 100%; }"
        print "tr {}" 
        print "th {}" 
        print "td {padding: 3px 10px;}" 
        print ".first {background-color:#FF66FF; color:white}"
        print ".second {background-color:#0066FF; color:white}"
        print "</style>"
        print "</head>"
        print "<body>"

        print "<h1 style=\"font-family:courier\">DIFFER REPORT</h1>"

        print "<table style=\"table-layout:fixed;width:500px;border:1px solid #B0B0B0\"><tr><th class=\"first\"><span>--- BASE </span></th><th class=\"second\"><span>+++ TARGET </span></th></tr><tr><th style=\"background-color:#ADADAD\">StartLineNumber,Length</th><th style=\"background-color:#ADADAD\">StartLineNumber,Length</th</tr><tr><td class=\"first\">-BaseChange</td><td class=\"second\">+TargetChange</td></tr></table><br>"

    }

    /^Only in/{
        if ( begin != 0 ) {
            print "</table>"
        } else {
            begin = 1
        }

        print "<hr/>"
        if (index($0,"BASE.TMP.DIR") != 0 ) { 
            print "<table><tr><th style=\"background-color:#CCFF00; color:black; width:50%\">"$0"</th><th> </th></tr>"
        } else if (index($0, "TARGET.TMP.DIR") != 0 ) { 
            print "<table><tr><th> </th><th style=\"background-color:#CCFF00; color:black; width:50%\">"$0"</th></tr>"
        } else {
            print "<table><tr><th style=\"color:purple\">"$0"</th></tr>"
        }
        next
    }

    / differ$/{
        if ( begin != 0 ) {
            print "</table>"
        } else {
            begin = 1
        }

        print "<hr/>"
        print "<table><tr><th style=\"background-color:#33FF00; color:black;\">"$0"</th></tr>"
        next
    }

    /^diff /{
        if ( begin != 0 ) {
            print "</table>"
        } else {
            begin = 1
        }

        print "<hr/>"
        print "<table>"

        next
    }

    /^--- /{
        print "<tr><th class=\"first\">"
        print "<span>"$0"</span>"
        print "</th>"
        next
    }

    /^\+\+\+ /{
        print "<th class=\"second\">"
        print "<span>"$0"</span>"
        print "</th></tr>"
        next
    }

    /^@@ /{
        split($0, t, " ")
        print "<tr><th style=\"background-color:#ADADAD\">"t[2]"</th><th style=\"background-color:#ADADAD\">"t[3]"</th></tr>"
        first_c = 0
        second_c = 0
        next
    }
    /^-/{
        if ( first_c == 0 && second_c == 0 ) {
            print "<tr>"
        }

        if ( first_c == 0 ) {
            print "<td class=\"first\">"
            first_c = 1
        }

        print "<span>"$0"</span>"
        print "<br/>"
        next
    }
    /^\+/{
        if ( first_c == 0 && second_c == 0 ) {
            print "<tr><td></td>"
        }

        if ( first_c == 1 ) {
            print "</td>"
            first_c = 0
        }
        
        if ( second_c == 0 ) {
            print "<td class=\"second\">"
            second_c = 1
        }

        print "<span>"$0"</span>"
        print "<br/>"
        next
    }

    {
        if ( first_c == 1 || second_c == 1 ){
            print "</td></tr>"
            first_c = 0
            second_c = 0
        }

        print "<tr>"
        print "<td>"$0"</td>"
        print "<td>"$0"</td>"
        print "</tr>"
    }

    END {
        print "</table>"

        print "</body>"
        print "</html>"
    }
