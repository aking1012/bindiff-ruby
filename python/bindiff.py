# bindiff PyCommand - (c)aking1012
# TODO: 
# - a LOT

import immlib
import immutils
import libdatatype
import getopt
from immlib import *
import socket

__VERSION__ = '0.la'
DESC        = 'A start on bindiff for immdbg'
ProgName    = 'bindiff'
ProgVers    = __VERSION__


def usage(imm):
    imm.log("%s v%s aking1012 -> team notATeam : response to a question on questions.securitytube.net" % (ProgName, ProgVers),focus=1, highlight=1)
    imm.log("!%s    Runs through all function calls and dumps the basic blocks for binary diff-ing" % (ProgName))
    imm.log("usage !bindiff -i modulename")
    imm.log("%s v%s aking1012 -> team notATeam : response to a question on questions.securitytube.net" % (ProgName, ProgVers),focus=1, highlight=1)

def main(args):
    imm = Debugger()
    include_pattern = exclude_pattern = None
    try:
        opts, args = getopt.getopt(args, "i:")
    except getopt.GetoptError:
        usage(imm)
        return "Incorrect arguments (Check log window)"
    for o, a in opts:
        if o == "-i":
            image_name = a
        else:
            usage(imm)
            return "Incorrect arguments (Check log window)"
    imm.markBegin()
    imm.log("Trying to open socket")
    try:
        bindiffsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    except socket.error, msg:
        imm.log("Fail.  Cannot create socket")
    try:
        bindiffsock.connect(("172.30.1.1", 8888))
    except socket.error, msg:
        imm.log("Failed to connect to host 172.30.1.1 on port 8888.  Check your addressing or modify me")
    module = imm.getModule( image_name )
    modadd = module.getBase()
    func_list = imm.getAllFunctions( modadd )
    i=0
    imm.log("Now dumping")
    for f in func_list:
        i=1+i
        function=imm.getFunction(f)
        sof = imm.getFunctionBegin(f)
        bindiffsock.send("sof:%x!" % (sof))
        imm.log("Start of function: %x" % (sof))
        basicblocks = function.getBasicBlocks(f)
        for bb in basicblocks:
            imm.log("   BBS:%x" % (bb.start))
            bindiffsock.send("BBS:%x!" % (bb.start))
            inst_set=bb.getInstructions(imm)
            for inst in inst_set:
                imm.log("       %s" % inst.result)
                bindiffsock.send("%s!" % inst.result)
            bindiffsock.send("BBE:%x!" % (bb.end))
            imm.log("   BBE:%x" % (bb.end))
        bindiffsock.send("eof: subtract size??whaaa?!")
    totaltime=imm.markEnd()
    bindiffsock.send("Duration: %d seconds...dumped.  Now for analysis. Will I be as fast as IDA dis + Turbodiff?!" % totaltime)
    bindiffsock.send("exit!")
    imm.log("Used time: %d seconds" % totaltime)
    bindiffsock.close()
    return "exit!"
