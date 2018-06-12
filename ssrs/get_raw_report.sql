 -- http://mscrmuk.blogspot.com/2009/05/reading-rdl-definitions-directly-from.html 
 SELECT Name, convert (varchar(max), convert (varbinary(max),[Content])) AS ReportRDL
 FROM [dbo].[Catalog] where TYPE =2
