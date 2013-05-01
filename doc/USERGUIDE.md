# Travel Support Program Application user guide

## About the application

The goal of this web based application is to offer a convenient way of managing
the requests and reimbursements from travel help programs of free software
organizations like the openSUSE Travel Support Program, the GNOME's Conference
Travel Subsidy Program or the KDE e.V. Travel Cost Reimbursement initiative.

Although been developed initially at the openSUSE Team at SUSE, the goal is to
write a generic application including all the common features so it can be extended
and adapted to fulfill the needs of any organization. As a result, the workflow
of requests and reimbursement processes can change. This document shows
workflow diagrams automatically generated from the current configuration.

## Applying for support

The whole process happens in the context of an event. In the events list (link
available in the sidebar menu) you can
see open events accepting sponsorship requests. Depending of the permissions
configuration, you will be able to create new events or only to apply to
previously existing events. You can click in the event name to access to the
general view of the event, which includes an 'apply' button/link. Clicking on it
creates a new 'request'.

You should fulfill all the information in the request form. The most important
information is probably the 'expenses' section, which describes how are you
planning to spend the money. You can add as many expenses as needed, specifying
the amount you are planning to spend on every one using the 'estimated
amount/currency' column. Sometimes you will know the
exact amount in advance and sometimes you will have to do an estimation.
Once you get a reply from the Travel Support Program managers, you will see real
approved amount for every expense in the 'approved amount' column. If you
finally accept the proposal, **you will only get the approved amount, not the
estimated one**. Keep this in mind.

You can save the request at any moment and edit it later, since it will be always
available in your requests list accessible through the sidebar menu. One
important note: creating, editing or saving your request DOES NOT send it to the
Travel Support Program managers. As long as the request state is 'incomplete',
it will be under your own control until you decide to change the state by using one
of the options in the 'action' dropdown button.

Understanding the 'state' field is the key for using the whole system since the
interaction between applicants, Travel Support Program members and other
individuals is performed by means of 'actions' which
change the 'state' of the request, always following the workflow diagram below.
![Request workflow diagram](Request_state.png)

Every time somebody changes the state of a request, he/she can write a message
explaining the reason of the change. Both the applicant and the Travel Support
Program members will be notified by mail. As and applicant, your goal should be
to reach the 'accepted' state. The state also determines who can modify the
request. For example, you will be able to change your request information while
it's on 'incomplete' state, but only Travel Support Program members can change
requests in 'submitted' state.
