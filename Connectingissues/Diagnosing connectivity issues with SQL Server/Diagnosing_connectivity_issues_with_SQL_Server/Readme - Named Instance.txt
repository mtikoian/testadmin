Filter on both tcp.port=1433 and TDS to demonstrate that we don't see any traffic:

tcp.Port==1433
or
tds


Next, filter on TLS to find the same pattern we saw in the default instance trace:


TLS


Since we know MSDTC is not involved in doing a SQL Server login, we need to use the other conversation (System).  Grab the port (50676) from that conversation and open the TCP parser.  Search for "1433" and add the line below to the parser:

case 50676:  //demo


Click on the "Rebuild Parsers" button.  (One way to shorten this step would be to already have a parser profile with this set.  You still have to rebuild, but it should be a little bit faster).

Right-click on one of the packets in the conversation and go to Find Conversation -> TCP.

Remove the TLS filter and you should see a typical login conversation.


