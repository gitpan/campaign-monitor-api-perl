CampaignMonitor PERL API by Nicolas Ramz <nicolas.ramz@gmail.com>

Purpose
-------

CampaignMonitor PERL API is a Perl class that is a BASIC implementation of some of Campaign Monitor's API methods.

This is my very first Perl module and should only be useful for starters. You've been warned :)

Methods currently implemented:
--
Client.GetLists
Subscriber.AddAndResubscribeWithCustomFields
Subscriber.AddWithCustomFields
Subscriber.Unsubscribe
Subscribers.GetIsSubscribed 
Subscribers.GetUnsubscribed
--


Requirements
------------

CampaignMonitor.pm requires the SOAP::Lite perl module



Usage
-----

See sample.pl


History
-------

 first public release
 --
 0.5: FIXED: API connection only requires API_Key (Client_ID is only required for some calls)
 0.4: cleaned up code

 internal release
 --
 0.3: ADDED: more calls, options parameter
 0.2: ADDED: nested array parameters
 0.1: initial release


Future
------

- Implement exceptions
- More API calls


Licence
-------

CampaignMonitor PERL API class is distributed under the MIT licence.

Copyright (c) 2009 Nicolas Ramz.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


Contact
-------

http://www.warpdesign.fr
http://www.warpdesign.fr/developers (coming soon)

nicolas (dot) ramz (at) gmail (dot) com