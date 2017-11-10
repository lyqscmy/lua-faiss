import sys

def gen_redis_proto(cmdstr):
    cmd = cmdstr.split(' ')
    proto= []
    proto.append("*")
    proto.append(str(len(cmd)))
    proto.append("\r\n")

    for i in cmd:
        proto.append("$")
        proto.append(str(len(str(i).encode())))
        proto.append("\r\n")
        proto.append(str(i))
        proto.append("\r\n")

    return "".join(proto)

for row in sys.stdin:
    row = row.split(' ')
    userID = row[0]
    weight = row[1]
    newsID = row[2]
    ZREMRANGEBYRANK = f"ZREMRANGEBYRANK text:offline:{userID} 0 -1"
    ZADD = f"ZADD text:offline:{userID} {weight} {newsID}"
    command = gen_redis_proto(ZREMRANGEBYRANK)
    sys.stdout.write(command)
    command = gen_redis_proto(ZADD)
    sys.stdout.write(command)
    # exit()
