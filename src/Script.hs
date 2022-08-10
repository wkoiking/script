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
-- srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2021-08-24-ew1-ahmedabad_v1.9"
-- srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-14-ew-ahmedabad"
-- srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-18-ew1-ahmedabad_v2.0_depot"
srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-08-10-ew-ahmedabad"
-- スクリプト

stopWorkstation120 :: IO ()
stopWorkstation120 = do
    sh $ do
        targetHost <- getOnlyReachables $ makeHosts 2 [20]
        killHascats targetHost

updateWorkstation120 :: IO ()
updateWorkstation120 = do
    sh $ do
        targetHost <- getOnlyReachables $ makeHosts 2 [20]
        updateHascatsWorkstation targetHost

startWorkstation120 :: IO ()
startWorkstation120 = sh $ do
    sh $ do
        targetHost <- getOnlyReachables $ makeHosts 2 [20]
        when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
            reboot targetHost
            return ()

-- Non EW1

stopCentralServers :: IO ()
stopCentralServers = do
    sh $ do
        targetHost <- getOnlyReachables $ centralServersEW1
        echo "Waiting 60s ..."
        endServer targetHost

stopNonEW1ServersAndWorkstations :: IO ()
stopNonEW1ServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables $ allServers \\ allServersEW1
        when (targetHost `elem` centralServersEW1) $ echo "Waiting 60s ..."
        endServer targetHost
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations \\ allWorkstationsEW1
        killHascats targetHost

updateNonEW1ServersAndWorkstations :: IO ()
updateNonEW1ServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables $ allServers \\ allServersEW1
        updateHascatsServer targetHost
--         startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations \\ allWorkstationsEW1
        updateHascatsWorkstation targetHost
--         reboot targetHost

startNonEW1ServersAndWorkstations :: IO ()
startNonEW1ServersAndWorkstations = sh $ do
    sh $ do
        targetHost <- getOnlyReachables $ allServers \\ allServersEW1
        when (targetHost `elem` centralServers) $ echo "Waiting 60s ..."
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations \\ allWorkstationsEW1
        when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
            reboot targetHost
            return ()

-- Workstation Only

stopNonEW1Workstations :: IO ()
stopNonEW1Workstations = do
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations \\ allWorkstationsEW1
        killHascats targetHost

updateNonEW1Workstations :: IO ()
updateNonEW1Workstations = do
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations \\ allWorkstationsEW1
        updateHascatsWorkstation targetHost
--         reboot targetHost

startNonEW1Workstations :: IO ()
startNonEW1Workstations = sh $ do
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations \\ allWorkstationsEW1
        when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
            reboot targetHost
            return ()

----------------------

removeKnownHosts :: IO ()
removeKnownHosts = mapM_ removeKnownHost $ allServers ++ allWorkstations

sshCopyIdAll :: IO ()
sshCopyIdAll = sh $ do
    targetHost <- getOnlyReachables $ allServers ++ allWorkstations
    sshCopyID targetHost

stopAllServersAndWorkstations :: IO ()
stopAllServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        when (targetHost `elem` centralServersEW1) $ echo "Waiting 60s ..."
        endServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        killHascats targetHost

stopNonCentralServers :: IO ()
stopNonCentralServers = do
    sh $ do
        targetHost <- getOnlyReachables $ makeHosts 1 [5, 6, 7, 8, 17, 18]
        if targetHost `elem` centralServersEW1
            then do
                echo "Waiting 60s ..."
                endServer targetHost
            else do
                killHascats targetHost

updateNonCentralServers :: IO ()
updateNonCentralServers = do
    sh $ do
        targetHost <- getOnlyReachables $ makeHosts 1 [5, 6, 7, 8, 17, 18]
        updateHascatsServer targetHost
--         startServer targetHost

updateAllServersAndWorkstations :: IO ()
updateAllServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        updateHascatsServer targetHost
--         startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        updateHascatsWorkstation targetHost
--         reboot targetHost

-- updateCentralServersAndTargetWorkstations :: IO ()
-- updateCentralServersAndTargetWorkstations = do
--     sh $ do
--         targetHost <- getOnlyReachables centralServersEW1
--         updateHascatsServer targetHost
--     sh $ do
--         targetHost <- getOnlyReachables targetWorkstationsEW1
--         updateHascatsWorkstation targetHost

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

startAllServersAndWorkstations :: IO ()
startAllServersAndWorkstations = sh $ do
    sh $ do
        targetHost <- getOnlyReachables allServers
        when (targetHost `elem` centralServers) $ echo "Waiting 60s ..."
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
            reboot targetHost
            return ()

startAllServers :: IO ()
startAllServers = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        when (targetHost `elem` centralServers) $ echo "Waiting 60s ..."
        startServer targetHost

startAllWorkstations :: IO ()
startAllWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
            reboot targetHost
            return ()

-- rebootAllWorkstatoins :: IO ()
-- rebootAllWorkstatoins = sh $ do
--     targetHost <- getOnlyReachables allWorkstations
--     when (targetHost `notElem` makeHosts 2 [45, 41]) $ do
--         reboot targetHost
--         return ()

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

allWorkstations :: [HostName]
allWorkstations = nub $ concat
    [ allWorkstationsEW1
    , makeHosts 2 [1, 2, 3, 8, 9, 10, 11, 13, 16, 20, 22, 31, 32, 33, 34, 35, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 80, 81, 82, 83]
    , makeHosts 4 [1, 2, 3, 4, 5, 6, 7, 20, 21, 22]
    , makeHosts 6 [3]
    , makeHosts 30 [1 .. 7]
    ]

centralServers :: [HostName]
centralServers = makeHosts 1 [1,2,3,4]

allServers :: [HostName]
allServers = makeHosts 1 [1..18]

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
