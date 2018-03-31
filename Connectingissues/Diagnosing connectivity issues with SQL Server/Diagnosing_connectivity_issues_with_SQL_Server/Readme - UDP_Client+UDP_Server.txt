These traces are pre-filtered down to just the SSRP traffic.

Explain that SSRP is the protocol used to talk to SQL Browser.
	=>UDP on tcp port 1434

Point out packets 37 (server) and 28 (client)
	->explain that since we see the packet leave the client and arrive at the server, we know this is not a Networking (i.e. infrastructure) issue
	->explain that we just are not seeing SQL Browser respond

Point out the next SSRP request in both traces and show that SQL Browser responds

Explain that the difference between the two requests was that the antivirus software on the machine had been disabled
	->if anybody asks, the ERROR on the server response packets is because the response got split over two packets and the second packets were accidentally filtered out of this trace.

