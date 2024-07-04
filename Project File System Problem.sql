-- Create the database
CREATE DATABASE storage;
GO

-- Use the new database
USE storage;
GO

-- Create the FileSystem table
CREATE TABLE FileSystem (
    NodeID INT PRIMARY KEY,
    NodeName VARCHAR(255),
    ParentID INT,
    SizeBytes INT
);

-- Insert sample data into the FileSystem table
INSERT INTO FileSystem (NodeID, NodeName, ParentID, SizeBytes) VALUES
(1, 'document', NULL, NULL),
(2, 'PICTURE', NULL, NULL),
(3, 'FILE1.TXT', 1, 500),
(4, 'FOLDER1', 1, NULL),
(5, 'IMAGE.JPG', 2, 1200),
(6, 'SUBFOLDER1', 4, NULL),
(7, 'FILE2.TXT', 4, 750),
(8, 'FILE3.TXT', 6, 300),
(9, 'FOLDER2', 2, NULL),
(10, 'FILE4.TXT', 9, 250);

-- Check the data
SELECT * FROM FileSystem;
GO


WITH FolderSizes AS (
    -- Base case: select all nodes and propagate their size, if present
    SELECT
        NodeID,
        NodeName,
        ParentID,
        COALESCE(SizeBytes, 0) AS SizeBytes
    FROM
        FileSystem

    UNION ALL

    -- Recursive case: accumulate sizes from child nodes
    SELECT
        f.NodeID,
        f.NodeName,
        f.ParentID,
        fs.SizeBytes
    FROM
        FileSystem f
    JOIN
        FolderSizes fs ON f.NodeID = fs.ParentID
),
TotalSizes AS (
    -- Calculate the total size for each node by summing the sizes of their descendants
    SELECT
        NodeID,
        NodeName,
        SUM(SizeBytes) AS TotalSizeBytes
    FROM
        FolderSizes
    GROUP BY
        NodeID, NodeName
)
SELECT
    fs.NodeID,
    fs.NodeName,
    COALESCE(ts.TotalSizeBytes, fs.SizeBytes) AS SizeBytes
FROM
    FileSystem fs
LEFT JOIN
    TotalSizes ts ON fs.NodeID = ts.NodeID
ORDER BY
    fs.NodeID;
GO
