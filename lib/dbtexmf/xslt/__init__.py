class XsltSetup:
    """
    Central XSLT setup, filled by the XML configuration
    """
    def __init__(self):
        self.command_pool = None

    def prepend_pool(self, pool):
        if self.command_pool:
            self.command_pool.prepend(pool)
        else:
            self.command_pool = pool


_xslt_setup = XsltSetup()
    
def xslt_setup():
    global _xslt_setup
    return _xslt_setup

