#include <zmq.hpp>
#include <string>
#include <iostream>

#ifndef _WIN32
#include <unistd.h>
#else
#include <windows.h>
#define sleep(n)    Sleep(n)
#endif

void process(zmq::socket_t* socket, std::string implementation, int m, int n) {
  std::cout << "Computing ack (" << m << ")(" << n << ")" << std::endl;

  std::ostringstream payload;
  payload << "{ \"fn\": \"ack\", \"m\": " << m << ",\"n\": " << n << " }";
  std::string json(payload.str());

  zmq::message_t request (json.length());
  void *data = request.data();

  memcpy (data, json.c_str(), json.length());

  std::cout << "(" << implementation << ") Computing ack (" << m << ")(" << n << ")" << std::endl;
  socket->send(request, zmq::send_flags::none);

  zmq::message_t raw_reply;
  socket->recv (raw_reply, zmq::recv_flags::none);

  char *my_reply = (char*) strndup((char*)raw_reply.data(), raw_reply.size());

  std::cout << "(" << implementation << ") Received result: " << my_reply << std::endl;
}

int main () {
  std::cout << "Connecting to the AckFibFac Crystal Server...";
  zmq::context_t context_crystal (1);
  zmq::socket_t socket_crystal (context_crystal, ZMQ_REQ);
  socket_crystal.connect("tcp://localhost:6666");
  std::cout << "connected!" << std::endl;

  std::cout << "Connecting to the AckFibFac Ruby Server...";
  zmq::context_t context_ruby (1);
  zmq::socket_t socket_ruby (context_ruby, ZMQ_REQ);
  socket_ruby.connect ("tcp://localhost:5555");
  std::cout << "connected!" << std::endl;


  while(1) {
    int n = rand() % 3 + 1;
    int m = rand() % 3 + 1;

    process(&socket_ruby, "Ruby", m, n);
    process(&socket_crystal, "Crystal", m, n);
  }
}
