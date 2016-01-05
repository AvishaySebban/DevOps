
LOG_BASE_DIR="/var/log/ntm-monitoring"
EXIT_CODE=0
ALERT_TYPE_CRITICAL="CRITICAL"
ALERT_TYPE_WARNING="WARNING"

#CPU
CPU_MAX_CRITICAL = 90
CPU_MAX_WARNING = 80

#DISK
DISK_MAX_CRITICAL = 15
DISK_MAX_WARNING = 20

#MEMO
MEMO_MAX_CRITICAL = 90
MEMO_MAX_WARNING = 80

#LOAD
LOAD_MAX_CRITICAL = 12
LOAD_MAX_WARNING = 10

host = "smtp.gmail.com"
subject = "Test email from NantCloud Monitoring"
to_addr = "avishay.saban@nantmobile.com"
from_addr = "python@mydomain.com"
body_text = "this email was sent automatically using monitoring alert"