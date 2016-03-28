#!/usr/bin/python

import smtplib
import base64

def sendMail(senderName,sender,reciever,subject,sub,body,filename,smtpServer):
    
    # Read a file and encode it into base64 format
    fo = open(filename, "rb")
    filecontent = fo.read()
    encodedcontent = base64.b64encode(filecontent)  # base64

    marker = "AUNIQUEMARKER"
    
    # Define the main headers.
    part1 = """From: """ + senderName + """ <""" + sender + """>
To: To Person <""" + reciever + """>
Subject: """ + subject +  """  """ + sub + """
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=%s
--%s
""" % (marker, marker)
    
    # Define the message action
    part2 = """Content-Type: text/plain
Content-Transfer-Encoding:8bit

%s
--%s
""" % (body,marker)
    
    # Define the attachment section
    part3 = """Content-Type: multipart/mixed; name=\"%s\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename=%s

%s
--%s--
""" %(filename, filename, encodedcontent, marker)
    message = part1 + part2 + part3
    
    try:
       smtpObj = smtplib.SMTP(smtpServer)
       smtpObj.sendmail(sender, reciever, message)
       print "Successfully sent email"
       return 0
    except Exception:
       print "Error: unable to send email"
       return 1
