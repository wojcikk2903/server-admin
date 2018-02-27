"""NCLab core configuration. """

# Mailgun settings
#MAILGUN_DOMAIN = "mg.nclab.com"
#MAILGUN_API_KEY = "key-82bc17d7c1bf83756b2336c5730efaec"
#
#EMAIL_HOST = 'smtp.mailgun.org'  # '10.8.3.1'
#EMAIL_PORT = 25
#EMAIL_SUBJECT_PREFIX = '[NCLab]'
#EMAIL_USER = 'postmaster@mg.nclab.com'
#EMAIL_PASS = 'ghT68s9#$ghio_'

MANDRILL_API_KEY         = "yJkCvydLZKy4mcMllgfVRw"
GOOGLE_ANALYTICS_API_KEY = 'UA-15768242-2'
MOUSEFLOW_API_KEY        = 'e95a4cec-2af0-4b27-9eb6-6471389b8f8c'

# Mandrill settings
EMAIL_HOST           = 'smtp.mandrillapp.com'
EMAIL_PORT           = 587
EMAIL_SUBJECT_PREFIX = '[NCLab]'
EMAIL_USER           = 'NCLab'
EMAIL_PASS           = 'yJkCvydLZKy4mcMllgfVRw'


DEFAULT_FROM_EMAIL = 'NCLab Team <office@nclab.com>'  # 'NCLab Team <no-reply@nclab.com>'
SERVER_EMAIL = DEFAULT_FROM_EMAIL
BUGREPORT_EMAIL = 'feedback@nclab.com'
ERRORS_TO_EMAIL = 'app-alerts@nclab.com'
SUPPORT_EMAIL = 'sales@nclab.com'
OUTBOX_EMAIL = 'outbox@nclab.com'
COURSE_FEEDBACK_EMAIL = 'coursefeedback@nclab.com'
ADMIN_NOTIFY_EMAIL = 'admin-notify@nclab.com'
FUNNEL_EMAIL = 'funnel@nclab.com'

WOOCOMMERCE_SERVER = 'https://nclab.com/wp-json/wc/v2/'
WOOCOMMERCE_CONSUMER_KEY = 'ck_64934a0089e040aa273d2ed48aaee130c669c3a7'
WOOCOMMERCE_CONSUMER_SECRET = 'cs_55c2d7e8edb977226ad27e568a7e076e980f8b95'
WOOCOMMERCE_KEY_OWNER = 'admin@nclab.com'

DATABASE = {
    'host': 'mongodb://int.mongo01.prod.nyc1.do.nclab.com,int.mongo02.prod.nyc1.do.nclab.com,'
            'int.mongo03.prod.nyc1.do.nclab.com',
    'db': 'nclab',
    #'read_preference': 'secondaryPreferred',
    'replica_set': 'nclabmongo',
    'username': 'ap_core',
    'password': 'ah%$_45HJUKL34',
    'ssl': True,
    'ssl_ca_certs': '/etc/ssl/mongo-CA-cert.crt'
    # 'port': 27017
}

REMOTE_MANAGER = "int.manager01.prod.nyc1.do.nclab.com"
REMOTE_TRANSLATIONS = "int.manager01.prod.nyc1.do.nclab.com"

LOG_NUM_BACKUPS = 240

UPDATE_SERVICE = '/home/lab/nclab service update'
UPDATE_CHROOT = 'ssh distribution@int.distro01.prod.nyc1.do.nclab.com ' \
                '/home/distribution/nclab-distribution-master/install.sh -r '

WEBSITE_URL = 'https://nclab.com'
ADMIN_URL = 'https://admin.nclab.com'
APP_URL = 'https://desktop.nclab.com'
VIEWER_URL = 'https://viewer.nclab.com'
LOGIN_URL = 'https://nclab.com/login/'

CDN = ["https://st.nclab.com", "https://st2.nclab.com", "https://st3.nclab.com"]
CDN_WEB = ["https://stweb.nclab.com", "https://stweb2.nclab.com", "https://stweb3.nclab.com"]

PORTS = [8000, 8001, 8002, 8003, 8004, 8005, 8006, 8007]
VIEWER_PORTS = [8010]
DEBUG = False
VALIDATE_EMAILS = True
DAEMON = True

WEBSERVER_GCORE = False  # Disabled because GDB does not work anyways
LOG_STD = True

CACHE_SIZE = 2048  # 2GB

# LOGSTASH_ADDRESS = 'manager'
# LOGSTASH_PORT = 7171

COOKIE_DOMAIN = ".nclab.com"

PAYPAL_RECEIVER_EMAIL = 'office@nclab.com'

IOLOOP_ALARM_TIME = 60

SERVICES = [
    # WHEN YOU ARE COMMENTING NODES OUT PLEASE WRITE DOWN THE REASON
   {'id': 'node01', 'hostname': 'int.compute01.prod.nyc1.do.nclab.com', 'user': 'lab', 'port': 9000, 'name': 'Node 1',
    'engines': ['Python', 'JavaScript', 'Octave', 'Latex', 'R', 'Python3', 'OpenSCAD'], 'commercial': True,
    'free': True, 'load': 1},
   {'id': 'node02', 'hostname': 'int.compute02.prod.nyc1.do.nclab.com', 'user': 'lab', 'port': 9000, 'name': 'Node 2',
    'engines': ['Python', 'JavaScript', 'Octave', 'Latex', 'R', 'Python3', 'OpenSCAD'], 'commercial': True,
    'free': True, 'load': 1},
   {'id': 'node03', 'hostname': 'int.compute03.prod.nyc1.do.nclab.com', 'user': 'lab', 'port': 9000, 'name': 'Node 3',
    'engines': ['Python', 'JavaScript', 'Octave', 'Latex', 'R', 'Python3', 'OpenSCAD'], 'commercial': True,
    'free': True, 'load': 1},
]

URL_MIME_TYPES_WHITELIST = ['image/jpeg', 'image/svg', 'image/svg+xml']
