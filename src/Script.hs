module Script
    ( module Project
    , module Turtle
    , module Util
    , module Script
    ) where

import Turtle hiding (nub)
import Prelude hiding (FilePath)
import Util
import Project
import Control.Monad
import Data.List

srcFileDir :: FilePath
-- srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-14-ew1-ahmedabad_v2.0_RC"
srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2021-08-24-ew1-ahmedabad_v1.9"
-- srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-14-ew-ahmedabad"
-- srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-17-ew-ahmedabad"

-- スクリプト

stopAllServersAndWorkstations :: IO ()
stopAllServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServersEW
        if targetHost `elem` centralServersEW1
            then do
                echo "Waiting 60s ..."
                endServer targetHost
            else do
                killHascats targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstationsEW
        killHascats targetHost

updateCentralServersAndTargetWorkstations :: IO ()
updateCentralServersAndTargetWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables centralServersEW1
        updateHascatsServer targetHost
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables targetWorkstationsEW1
        updateHascatsWorkstation targetHost
        reboot targetHost

startAllServersEW1AndWorkstationsEW1 :: IO ()
startAllServersEW1AndWorkstationsEW1 = sh $ do
    sh $ do
        targetHost <- getOnlyReachables $ allServersEW1 \\ centralServersEW1
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstationsEW1 \\ targetWorkstationsEW1
        when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
            reboot targetHost
            return ()

-- よく使うIPアドレスのリストの定義

centralServersEW1 :: [HostName]
centralServersEW1 = makeHosts 1
    [1, 2]

allServersEW1 :: [HostName]
allServersEW1 = makeHosts 1
    [1,2,5,6,7,8,17,18]

targetWorkstationsEW1 :: [HostName]
targetWorkstationsEW1 = concat
    [ makeHosts 2 [1, 2, 80]
    , makeHosts 4 [1, 2, 7, 21]
    ]

allWorkstationsEW1 :: [HostName]
allWorkstationsEW1 = concat
    [ makeHosts 2 $ concat
        [ [1, 2, 3]
        , [8, 9, 10, 11]
        , [13, 16, 20]
        , [40 .. 48]
        , [80, 81]
        ]
    , makeHosts 4 [1, 2, 7, 21]
    ]

allWorkstationsEW :: [HostName]
allWorkstationsEW = nub $ concat
    [ allWorkstationsEW1
    , makeHosts 2 [1, 2, 3, 8, 9, 10, 11, 13, 16, 20, 22, 31, 32, 33, 34, 35, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 80, 81, 82, 83]
    , makeHosts 4 [1, 2, 3, 4, 5, 6, 7, 20, 21, 22]
    , makeHosts 6 [3]
    ]

allServersEW :: [HostName]
allServersEW = makeHosts 1 [1..18]

-- アップデートコマンド

updateHascatsServer :: MonadIO io => HostName -> io ExitCode
updateHascatsServer targetHost = do
    let srcFilePath = srcFileDir </> serverBinaryName
    let dstFilePath = makeBinaryFilePath serverBinaryName
    scp srcFilePath targetHost dstFilePath

updateHascatsWorkstation :: MonadIO io => HostName -> io ExitCode
updateHascatsWorkstation targetHost = do
    let srcFilePath = srcFileDir </> workstationBinaryName
    let dstFilePath = makeBinaryFilePath workstationBinaryName
    scp srcFilePath targetHost dstFilePath
