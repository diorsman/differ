#!/user/bin/env awk
    BEGIN {
        begin = 0

        print "<html>"
        print "<head>"
        print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
        print "<title>REPORT</title>"
        print "<style type=\"text/css\">" 
        print "body {}"
        print "h1 {text-align: center; color: blue}"
        print "table {width: 100%; }"
        print "tr {}" 
        print "th {text-align: center; background: -moz-linear-gradient(top, #F0F0F0 0, #DBDBDB 100%); background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #F0F0F0), color-stop(100%, #DBDBDB)); filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#F0F0F0', endColorstr='#DBDBDB', GradientType=0); border: 1px solid #B0B0B0; color: #444; font-size: 16px; font-weight: bold; padding: 3px 10px;}" 
        print ".th2 {text-align: center; background: -moz-linear-gradient(top, #F0F0F0 0, #DBDBDB 100%); background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #F0F0F0), color-stop(100%, #DBDBDB)); filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#F0F0F0', endColorstr='#DBDBDB', GradientType=0); border: 0px solid #B0B0B0; color: #444; font-size: 16px; font-weight: bold; padding: 3px 10px;}" 
        print "td {padding: 3px 10px;}" 
        print ".first {color: green}"
        print ".second {color: red}"
        print "</style>"
        print "</head>"
        print "<body>"

        print "<h1>DIFFER REPORT</h1>"

        print "<table style=\"table-layout:fixed;width:300px;border:1px solid #B0B0B0\"><tr><th><span class=\"first\">--- BASE </span><span class=\"second\">+++ TARGET </span></th></tr><tr><td class=\"th2\">@@LineNumber@@</td></tr><tr><td class=\"first\">-BaseChange</td></tr><tr><td class=\"second\">+TargetChange</td></tr></table><br>"

    }

    /^Only in/{
        if ( begin != 0 ) {
            print "</table>"
        } else {
            begin = 1
        }

        print "<br>"
        print "<table><tr><th>"$0"</th></tr>"
        next
    }

    /^diff /{
        if ( begin != 0 ) {
            print "</table>"
        } else {
            begin = 1
        }

        print "<br>"
        print "<table>"

        next
    }

    /^--- /{
        print "<tr><th>"

        print "<span class=\"first\">"$0"</span>"
        next
    }

    /^\+\+\+ /{
        print "<span class=\"second\">"$0"</span>"

        print "</th></tr>"
        next
    }

    /^@@ /{
        print "<tr><td class=\"th2\">"$0"</td></tr>"
        next
    }
    /^-/{
        print "<tr><td><span class=\"first\">"$0"</span></td></tr>"
        next
    }
    /^\+/{
        print "<tr><td><span class=\"second\">"$0"</span></td></tr>"
        next
    }
    / differ$/{
        print "<tr><td class=\"th2\">"$0"</td></tr>"
        next
    }

    {
        print "<tr><td>"$0"</td></tr>"
    }

    END {
        print "</table>"

        print "</body>"
        print "</html>"
    }
