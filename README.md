# abap-cloud-appljob
**Working with Application Jobs in ABAP Cloud**


**Introduction**

Classic batch jobs on the ABAP Application Server for S/4HANA Cloud and the BTP ABAP Environment have been replaced by application jobs. From what I could research myself, this new framework builds on the existing classical batch job functionality adding a modern layer on top and also some extensions. For ABAP developers working in cloud systems, automating tasks and setting up periodic maintenance jobs remains a valid requirement. However, the new application job framework introduces some challenges that I, too, encountered.

**Challenges in Working with Application Jobs and Possible Solutions**

Like other aspects in the ABAP Cloud, working with the new application job framework comes with some obstacles, but these are not unsolvable.
- Adding visible application log to the application job
- Scheduling a background job with a technical user
- Preventing Multiple Instances of a Job from Running Simultaneously
- Debugging an application job
 
To tackle some of the challenges mentioned above, I built custom small tools with the following principles in mind:
- They should never interfere with job execution (exceptions are caught without propagation).
- They should use method chaining, inspired by the XCO Library, for easy implementation and removal when no longer needed.
- They should have short, meaningful descriptions and keywords for easy usage without additional documentation.

This repository contains the code for these tools. Checkout class zcl_os_demo_appl_job to see how these tools can be used.


