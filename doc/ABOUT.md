# About this application

## Who

There are two possible questions regarding the 'who'. The first one is: who is
developing it? The answer is that this application is another open project from
the openSUSE team at SUSE Linux, what means that development is open to
everybody who wants to contribute or fork.

The second question is who is intended to use it. There are four different user
profiles or roles commonly involved in travel support programs:

* Requesters, that is, every open source contributor applying for support in
order to assist to an event.
* Travel Support Program Committe members. In most free software organizations
there is a group of people that must evaluate every request to decide how much
money, if any, should the requester have reimbursed.
* Administrative or accounting responsible. After the Committe have approved a
a reimbursement it usually goes through some kind of financial circuit before
the requester gets the money, so somebody have to be in charge of managing such
process.
* Supervisors for the whole process, like the organization boards or enterprise
sponsors.

## What

Basically, at the moment of writing the application manages two main use cases:
the request of a new sponsorship for a given event and the reimbursement
proccess which takes place just after the event ends.

The workflow of the first case is presented in the following diagram. The
requester asks for support detailing the total estimated cost of every involved
expense and the TSP Committee can approve a given amount for every expense.
Finally, the explicit requester's acceptance is required.
![Request workflow diagram](Request_state.png)

Once the requester have attended to the event, he/she must provide some reports
in order to get access to the reimbursement, including digitalized copies of
invoices for every expense. Once again, this reports are validated and approved
by the Committee. After this validation, the reimbursement must be verified by
the accounting responsible before the payment order can be issued. Both whether
the requester confirms the payment once receiveid or not, somebody from the TSP
Committee or from the administrative department must verify that everything was
ok and mark the reimbursement process as completed.
![Reimbursement workflow diagram](Reimbursement_state.png)

## When

For obvious reasons, requests should be accepted before the event starts.
Usually there is a maximum period of time for reimbursements after the event
have finished. Requests and reimbursements exceding those time limits would be
cancelled.

## Where

Well, the goal of travel support programs is, precisely, to reduce the impact
of phisycal and economic barriers. So the answer to the 'where' question should
be: all over the world through Internet!

## Why

## How

The goal of this application is to fullfil all the requirements while providing
the following features:

* Full functionality available through web interface and through a REST json
  API.
* Themeable and responsive web interface based on
  [Bootstrap](http://github.com/twitter/bootstrap).
* Flexible user system with pluggable backends (so the application can be
  integrated in previously existing users infrastructures) based on
  [Devise](https://github.com/plataformatec/devise).
* Robust control over information access and full log of information
  modifications.
* Fully documented with information automatically generated from the source code
  (diagrams, API documentation, etc.)
* Good tests coverage.
