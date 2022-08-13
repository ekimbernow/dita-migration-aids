# dita-migration-aids

Tools that aid in the migration of DITA content from DITA 1.x to 2.0

This repository contains various tools for analyzing DITA content and performing content migrations.

## Tools Supported

The aids in this repository are implemented as XQuery 3.1 queries and XSLT 3 transforms. They are intended to be used in a more-or-less ad-hoc way as you prepare for and perform content migration from DITA 1.x to 2.0.

They can be used with tools that support XQuery 3.1 and XSLT 3, including:

* OxygenXML
* Saxon
* BaseX
* eXist
* MarkLogic

These tools have been developed using OxygenXML and BaseX. They may need minor adjustment to work with other tools.

### Use of Open Toolkit

DITA Open Toolkit version 3.7 includes the DITA 2.x DTDs and grammars and provides a master XML entity resolution catalog that can be used with tools that support catalogs, including OxygenXML, BaseX, and Saxon.

### OxygenXML

OxygenXML provides general facilities for running XSLT transforms and XQuery update scripts against DITA content.

In addition, SyncRO Soft have developed a set of OxygenXML refactor scripts for migrating from DITA 1.x to 2.0.

OxygenXML makes it easy to apply updating refactors to large bodies of content. Even a refactor that updates tens of thousands of topics may only take a few minutes to run.

### Use of BaseX

The BaseX XQuery database is an easy-to-use Java-based XQuery basebase that makes it easy to do fast queries across large amounts of DITA content. These BaseX queries can be much faster than the same queries performed by OxygenXML against the file system. If you have more than a few hundred topics and maps to be migrated BaseX can represent a significant time savings.

The aids provided here include a simple BaseX-based web application that produces an HTML report of the migrations required for a given body of content.

## BaseX Migration Analysis Application

To use the BaseX migration analysis application perform the following steps:

1. Download the BaseX Zip distribution (macOS and linux) or Windows installer (Windows): https://basex.org/download/
1. Copy the `basex/webapp/dita-migration` directory into the BaseX `webapp` directory
1. Start the BaseX http server per the BaseX documentation (starting version 10 you need to set the admin password when you start the server for the first time: `basexhttp -c PASSWORD` where `PASSWORD` is the literal string `PASSWORD`, meaning the `PASSWORD` command.
1. Navigate to `http://localhost:nnnn/dita-migration` where `nnnn` is the port number for the BaseX web server (8984 for BaseX 9 and earlier, 8080 for BaseX 10 and newer).
1. Follow the instructions for creating a BaseX database with your DITA content to be analyzed.
1. Follow the instructions for generating a migration analysis report.