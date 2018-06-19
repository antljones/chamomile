While Unit Testing is a common practice in most modern programming languages, SQL practitioners do not commonly create or use Unit Tests, and there does not seem to be an accepted standard practice for creating and using Unit Tests. A great part of the reason for this is the difficulty involved in creating and maintaining Mock Data.

This article introduces a technique for Unit Testing using SQL stored procedures and transactions with no external framework or Mock Data required. Additionally, the resultant test procedures may be left in place as a test harness for production code.
