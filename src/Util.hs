module Util where

import Turtle
import qualified Data.Text as T
import Prelude hiding (FilePath)
import Project

type HostName = Text

quote :: Text -> Text
quote x = mconcat ["\"", x, "\""]

permission :: Text
permission = "755"

cmd :: MonadIO io => Text -> io ExitCode
cmd str = shell str empty

tshow :: Show a => a -> Text
tshow = T.pack . show

sshCmd' :: MonadIO io => HostName -> Text -> Shell Line -> io ExitCode
sshCmd' targetIP cmdStr stdin = shell (format ("ssh "%s%"@"%s%" "%s) user targetIP (quote cmdStr)) stdin

sshCmd :: MonadIO io => HostName -> Text -> io ExitCode
sshCmd targetIP cmdStr = sshCmd' targetIP cmdStr mempty

scp :: MonadIO io => FilePath -> HostName -> FilePath -> io ExitCode
scp srcFilePath targetIP dstFilePath
    = cmd $ format ("scp -p "%fp%" "%s%"@"%s%":"%fp) srcFilePath user targetIP dstFilePath

reboot :: MonadIO io => HostName -> io ExitCode
reboot targetIP = sshCmd targetIP cmdStr
 where cmdStr = format ("echo "%s%" | sudo -S reboot &>/dev/null") password

killHascats :: MonadIO io => HostName -> io ExitCode
killHascats targetIP = do
    printf "Killing hascats-exe\n"
    sshCmd targetIP "pkill hascats-exe"

endServer :: MonadIO io => HostName -> io ExitCode
endServer targetIP = sshCmd targetIP "bash ./VDU/EndServer.sh"

startServer :: MonadIO io => HostName -> io ExitCode
startServer targetIP = sshCmd' targetIP "bash ./VDU/StartServer.sh &>/dev/null" ""

makeHosts :: Int -> [Int] -> [HostName]
makeHosts thirdOct ns = map makeHost ns
 where makeHost n = format ("172.21."%w%"."%d) (100 + thirdOct) n

chmodRemote :: MonadIO io => HostName -> FilePath -> Text -> io ExitCode
chmodRemote targetIP dstFilePath permission = sshCmd targetIP cmdStr
 where cmdStr = format ("chmod "%s%" "%fp) permission dstFilePath

makeBinaryFilePath :: FilePath -> FilePath
makeBinaryFilePath binaryName = "/home" </> user' </> ".local/bin" </> binaryName
 where user' = fromString $ T.unpack user

removeKnownHost :: MonadIO io => HostName -> io ExitCode
removeKnownHost targetIP = cmd $ format ("ssh-keygen -f "%s%" -R "%s) knowHostsPath targetIP
 where knowHostsPath = quote "/home/nao/.ssh/known_hosts"

sshCopyID :: MonadIO io => HostName -> io ExitCode
sshCopyID targetIP = shell (format ("ssh-copy-id "%s%"@"%s) user targetIP) mempty

fromHostToIP :: HostName -> Text
fromHostToIP host
    | user <> "@" == hostStr = ipAddr
    | otherwise = host
 where (hostStr, ipAddr) = T.splitAt (T.length user + 1) host

ping :: MonadIO io => HostName -> io (HostName, ExitCode)
ping targetIP = do
    (code, _) <- shellStrict (format ("ping -w 3 "%s) targetIP) mempty
    return (targetIP, code)

getOnlyReachables :: [HostName] -> Shell HostName
getOnlyReachables targetIPs = do
    awaits <- mapM (fork . ping) targetIPs
    await <- select awaits
    (host, code) <- wait await
    case code of
        ExitSuccess -> do
            printf ("Processing "%s%"\n") host
            return host
        ExitFailure _ -> do
            printf (s%" is not reachable ... skipping\n") host
            empty

areReachable :: MonadIO io => [HostName] -> io ()
areReachable targetIPs = sh $ do
    awaits <- mapM (fork . ping) targetIPs
    await <- select awaits
    (host, code) <- wait await
    case code of
        ExitSuccess -> printf (s%": success\n") host
        ExitFailure _ -> printf (s%": failure\n") host
