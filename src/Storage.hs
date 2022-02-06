module Storage where

import Data.ByteString as B
import Data.Hashable
import System.Posix.Files

store :: FilePath -> B.ByteString -> IO ()
store path content = store <> catalog
                where
                data_path = show . hash $ content
                store = B.writeFile data_path content
                catalog = createLink data_path path

retrieve = B.readFile

delete :: FilePath -> IO ()
delete = removeLink
