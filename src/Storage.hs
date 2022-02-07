module Storage where

import Data.ByteString as B
import Data.Hashable
import System.Posix
import System.Directory.Extra
import Control.Monad.Extra
import Data.Function.Slip

type Bucket = String
type ObjID = Int
type Content = ByteString

store :: Bucket -> ObjID -> B.ByteString -> IO ()
store bucket obj content =
    ensureBucketExists bucket <>
    whenM (isDuplicate bucket content) store <>
    ref
                where
                obj_paths = path bucket obj
                storage = data_path bucket content
                store = B.writeFile storage content
                ref = createLink storage (obj_paths "/objects/")
                      <> createSymbolicLink storage  (obj_paths "/refs/")

retrieve :: Bucket -> ObjID -> IO ByteString
retrieve = ((.) . (.)) B.readFile (slipl path "/objects/")

delete :: Bucket -> ObjID -> IO ()
delete bucket obj = whenM ((>= 2) <$> exemplarOf bucket obj) unstore
                       <> unref
                where
                obj_paths = path bucket obj
                unref = removeLink (obj_paths "/objects/")
                     <> removeLink (obj_paths "/refs/")
                unstore = readSymbolicLink (obj_paths "/refs/")
                      >>= removeLink

ifObj bucket obj f = whenMaybeM
                        (fileExist $ path bucket obj "/buckets/") $
                        f bucket obj

data_path :: Bucket -> Content -> FilePath
data_path bucket content = bucket <> "/store/" <> (show . hash) content

exemplarOf :: Bucket -> ObjID -> IO LinkCount
exemplarOf b i = fmap linkCount $ getFileStatus $ b <> "/refs/" <> show i

isDuplicate :: Bucket -> Content -> IO Bool
isDuplicate =  ((.) . (.)) fileExist data_path

path ::  Bucket -> ObjID -> String -> FilePath
path b obj what =  b <> what <> show obj

ensureBucketExists bucket = foldMap (
                                createDirectoryIfMissing True . (bucket <>))
                                ["refs", "objects", "store"]
