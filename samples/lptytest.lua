require "lpty"

p = lpty.new()

ntests = 0
nfailed = 0

-- announce which test we are performing and what it tests
function announce(str)
	str = str or ""
	ntests = ntests + 1
	print("Test " .. tostring(ntests) .. ": " .. str)
end

-- print that the test did not ork out and optionally why
function fail(str)
	local msg = "  TEST FAILED"
	nfailed = nfailed + 1
	if str ~= nil then msg = msg .. ": " .. str end
	print(msg)
end

-- just prints wether the test went ok or not. An optional reason for failure may be passed,
-- which will then be printed.
function check(ok, msg)
	if ok==false then
		fail(msg)
	else
		print "  TEST OK"
	end
end

-- wait for a fraction of a second
function waitabit(n)
	n = n or 1
	t0 = os.clock()
	t1 = t0
	while t1 - t0 < 0.1 * n do
		t1 = os.clock()
	end
end

-- 1
announce("starting test client")
ok, val = pcall(lpty.startproc, p, "lua", "testclient.lua")
if ok then
	check(val)
else
	fail(tostring(val))
end

-- 2
announce("checking whether pty has process, should return true")
ok, val = pcall(lpty.hasproc, p)
if ok then
	check(val)
else
	fail(tostring(val))
end

-- 3
announce("checking whether we can read from the pty, should return false")
ok, val = pcall(lpty.readok, p)
if ok then
	check(val == false)
else
	fail(tostring(val))
end

-- 4
announce("reading from pty with a timeout of 1 second, should return nil")
ok, val = pcall(lpty.read, p, 1)
if ok then
	check(val == nil)
else
	fail(tostring(val))
end

-- 5
announce("checking whether we can write to the pty, should return true")
ok, val = pcall(lpty.sendok, p)
if ok then
	check(val)
else
	fail(tostring(val))
end

-- 6
announce("writing data 'abcba\\n' to the pty, should return length of data -> 6")
ok, val = pcall(lpty.send, p, "abcba\n")
if ok then
	check(val == 6)
else
	fail(tostring(val))
end

-- allow the client to react
waitabit()

-- 7
announce("checking whether we can read from the pty, should return true")
ok, val = pcall(lpty.readok, p)
print(val)
if ok then
	check(val)
else
	fail(tostring(val))
end

-- 8
announce("reading from pty, should return 'abcba\\n+abcba+\\n'")
ok, val = pcall(lpty.read, p, 1)
if ok then
	val = string.gsub(val, "[\r\n]+", '.') -- normalize line endings
	check(val == "abcba.+abcba+.")
else
	fail(tostring(val))
end

-- 9
announce("terminating child process")
ok = pcall(lpty.endproc, p)
check(ok)

-- allow client to terminate
waitabit()

-- 10
announce("Checking whether pty has child process, should return false")
ok, val = pcall(lpty.hasproc, p)
if ok then
	check(val == false)
else
	fail(tostring(val))
end

-- 11
announce("checking wheter we can read from pty, should return false")
ok, val = pcall(lpty.readok, p)
if ok then
	check(val == false)
else
	fail(tostring(val))
end

-- 12
announce("reading from pty with a timeout of 1 second, should return nil")
ok, val = pcall(lpty.read, p, 1)
if ok then
	check(val == nil)
else
	fail(tostring(val))
end

-- test timeut length. In order for this to work there may be no pending data in the pty to read.
function testto(to, tm)
	local t0 = os.time()
	local i
	for i=1,10 do
		p:read(to)
	end
	local t = os.time() - t0
	-- allow for some deviation
	return (tm - 1 < t and t < tm + 1)
end

-- 13
announce("testing timeout 1 second by running r:read(1) 10 times should take about 10 seconds")
check(testto(1, 10))

-- 13
announce("testing timeout 0.5 second by running r:read(1) 10 times should take about 5 seconds")
check(testto(0.5, 5))

-- 13
announce("testing timeout 1.5 second by running r:read(1) 10 times should take about 15 seconds")
check(testto(1.5, 15))

-- all done
print("Tests " .. tostring(ntests) .. " failed " .. tostring(nfailed))
