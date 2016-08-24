import private/sockets, private/messaging
import os,threadpool

type KernelObj = object
  hb*: Heartbeat # The heartbeat socket object
  shell*: Shell
  #shell: Shell
type Kernel = ref KernelObj


proc init( connmsg : ConnectionMessage) : Kernel =
  echo "[Nimkernel]: Initing"
  new result
  result.hb = createHB(connmsg.ip,connmsg.hb_port) # Initialize the heartbeat socket
  result.shell = createShell( connmsg.ip, connmsg.shell_port, connmsg.key )

proc shutdown(k: Kernel) =
  echo "[Nimkernel]: Shutting Down"

let arguments = commandLineParams() # [0] should always be the connection file

assert(arguments.len>=1, "[Nimkernel]: Something went wrong, no file passed to kernel?")

var connmsg = arguments[0].parseConnMsg()

var kernel :Kernel = connmsg.init()

spawn kernel.hb.beat()

for i in 0..5:
  kernel.shell.receive()