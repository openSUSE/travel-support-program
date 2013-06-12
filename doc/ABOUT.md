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
* Travel Support Program Committee members. In most free software organizations
there is a group of people that must evaluate every request to decide how much
money, if any, should the requester have reimbursed.
* Administrative or accounting responsible. After the Committee have approved a
a reimbursement it usually goes through some kind of financial circuit before
the requester gets the money, so somebody have to be in charge of managing such
process.
* Supervisors for the whole process, like the organization boards or enterprise
sponsors.

## What

Basically, at the moment of writing the application manages two main use cases:
the request of a new sponsorship for a given event and the reimbursement
process which takes place just after the event ends.

The workflow of the first case is presented in the following diagram. The
requester asks for support detailing the total estimated cost of every involved
expense and the TSP Committee can approve a given amount for every expense.
Finally, the explicit requester's acceptance is required.

![Request workflow diagram](Request_state.png)

Once the requester have attended to the event, he/she must provide some reports
in order to get access to the reimbursement, including digitized copies of
invoices for every expense. Once again, this reports are validated and approved
by the Committee. After this validation, the reimbursement must be verified by
the accounting responsible before the payment order can be issued.

![Reimbursement workflow diagram](Reimbursement_state.png)

## When

For obvious reasons, requests should be accepted before the event starts.
Usually there is a maximum period of time for reimbursements after the event
have finished. Requests and reimbursements exceding those time limits could be
cancelled.

## Where

Well, the goal of travel support programs is, precisely, to reduce the impact
of physical and economic barriers. So the answer to the 'where' question should
be: all over the world by means of Internet!

## Why

The main reason for developing a new application for an already working process
or workflow is usually the same: the need of a closer control in order to have
a better feedback about the process status and better reporting capabilities.

The application should enhance the process from the points of view of all
involved people, not only providing up to date information about the status of
every request and reimbursement process, but also sending mail notifications
everytime something which requires some action happens and sending mail reminder to the
involved people if a particular request or reimbursement gets stuck in the same
status for too much time.

From a more general point of view, the application should allow better
management of the travel support program, both from an operative and from an
economic point of view. A fully structured information system can provide good
automatically generated reports and allows both the travel support program
responsible and the supervisors to set fixed or approximate budgets per period
or per event, well as minimum warranted available amounts or as maximum limits.

In order to allow this control options, the events have a central role in the
application, being the point of entry for the whole process. Selecting an event
(or introducing all the information if it does not exists yet) is the first
stage for every subsequent action. Gathering complete information about the
events involved in the program is also an important goal for the project.

## How

The goal of this application is to fulfill all the requirements while providing
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
