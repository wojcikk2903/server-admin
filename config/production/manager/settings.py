"""NCLab core configuration. """

DATABASE = {
    'host': 'mongodb://mongo01.prod.nyc1.do.nclab.com,mongo02.prod.nyc1.do.nclab.com,mongo03.prod.nyc1.do.nclab.com',
    'db': 'nclab',
    'read_preference': 'secondaryPreferred',
    'replica_set': 'nclabmongo'
    # 'port': 27017
}

REMOTE_CORE = "https://desktop.nclab.com"

IOLOOP_ALARM_TIME = 240
