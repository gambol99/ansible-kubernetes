import re

def without_service(string):
    return re.sub(r"[-_]service$", "", string+"")

class FilterModule(object):
    def filters(self):
        return {
            'without_service': without_service
        }
