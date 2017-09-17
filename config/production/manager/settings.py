"""NCLab core configuration. """

DATABASE = {
    'host': 'mongodb://int.mongo01.prod.nyc1.do.nclab.com,int.mongo02.prod.nyc1.do.nclab.com,'
            'int.mongo03.prod.nyc1.do.nclab.com',
    'db': 'nclab',
    'read_preference': 'secondaryPreferred',
    'replica_set': 'nclabmongo',
    'username': 'ap_manager',
    'password': ''
    # 'port': 27017
}

REMOTE_CORE = "https://desktop.nclab.com"

IOLOOP_ALARM_TIME = 240
