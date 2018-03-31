TDS filter
(typically, you could use tcp.port==1433, but my environment uses a proxy.  You can see this by looking at the WSP detail in the Frame Details window)

Then, right-click -> Find Conversations -> TCP

Remove the TDS filter

Everything is encrypted!!

Even though the login is encrypted, you can still see the PreLogin handshake to confirm you made it to SQL Azure
