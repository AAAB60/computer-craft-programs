mags = peripheral.find("create:adjustable_crate")
bottler = peripheral.find("minecraft:trapped_chest")
shovel = peripheral.find("minecraft:barrel")
loader = peripheral.find("minecraft:chest")
unloader = peripheral.find("minecraft:hopper")
analyser = peripheral.find("thermal:machine_centrifuge")
table1 = {["Andesite Reagent"]=1,["Diorite Reagent"]=2,["Granite Reagent"]=3,["Stone Reagent"]=4,["Basalt Reagent"]=5,["Gabbro Reagent"]=6,
["Crimson Reagent"]=1,["Orange Reagent"]=2,["Goldenrod Reagent"]=3,["Olive Reagent"]=4,["Azure Reagent"]=5,["Fuchsia Reagent"]=6,
["Blazing Reagent"]=1,["Slime Reagent"]=2,["Nether Reagent"]=3,["Obsidian Reagent"]=4,["Gunpowder Reagent"]=5,["Aquatic Reagent"]=6,
["Arcane Reagent"]=1,["Apatite Reagent"]=2,["Sulfuric Reagent"]=3,["Nitric Reagent"]=4,["Certus Quartz Reagent"]=5,["Nether Quartz Reagent"]=6,
["Zinc Reagent"]=1,["Copper Reagent"]=2,["Iron Reagent"]=3,["Nickel Reagent"]=4,["Lead Reagent"]=5,["Gold Reagent"]=6,
["Cinnabar Reagent"]=1,["Lapis Lazuli Reagent"]=2,["Sapphire Reagent"]=3,["Emerald Reagent"]=4,["Ruby Reagent"]=5,["Diamond Reagent"]=6}
function tableCopy(b)
    local a = {}
    for i ,j in pairs(b) do
        if type(j) == "table" then
            local jundge = nil
            for m,n in pairs(j) do --{} ~= {}
                jundge = true
                break
            end
            if jundge then
                a[i] = tableCopy(j)
            else a[i] = {}
            end
        else
            a[i] = j
        end
    end
    return a
end
function tableCompare(a,b)
    local jundge = true
    for i = 1,#a do
        if type(a[i]) == "table" then
            if #a[i] ~= 0 and not tableCompare(a[i],b[i]) then
                jundge = false
                break
            elseif #a == 0 and #b[i] ~= 0 then
                jundge = false
                break
            end
        elseif a[i] ~= b[i] then
            jundge = false
            break
        end
    end
    return jundge
end
function tableCompare1(a,b)
    local jundge = false
    for i = 1,#a do
        if tableCompare(a[i],b) then
            jundge = true
            break
        end
    end
    return jundge
end
local function push(container,receive,count,toslot,nameDisplay)--(dirt,dirt/"minecraft:chest_0")
    local num,receiveName = 0,""
    if type(receive) == "string" then
        receiveName = receive
    else
        receiveName = peripheral.getName(receive)
    end
    --negelect modle
    if nameDisplay == nil then
        if count ~= nil then
            for i,j in pairs(container.list()) do
                num = num + j["count"]
                container.pushItems(receiveName,i,count - num + j["count"],toslot)
                if num >= count then break end
            end
        else 
            for i,j in pairs(container.list()) do
                container.pushItems(receiveName,i,nil,toslot)
            end
        end
    else
        if count ~= nil then
            for i,j in pairs(container.list()) do
                if container.getItemDetail(i).displayName == nameDisplay then
                    num = num + j["count"]
                    container.pushItems(receiveName,i,count - num + j["count"],toslot)
                    if num >= count then break end
                end
            end
        else 
            for i,j in pairs(container.list()) do
                if container.getItemDetail(i).displayName == nameDisplay then
                    container.pushItems(receiveName,i,nil,toslot)
                end
            end
        end
    end
end
local function push1(container,outPutRules)--{{"Dirt","minecraft:chest_1",[num],toslot},{"Dirt","cobblesStone"}}
    for i,j in pairs(container.list()) do
        local displayName1,receiveName = container.getItemDetail(i).displayName,""
        for m,n in pairs(outPutRules) do
            if type(n[2]) == "string" then
                receiveName = n[2]
            else
                receiveName = peripheral.getName(n[2])
            end
            if displayName1 == n[1] then
                container.pushItems(receiveName,i,n[3],n[4])
                break
            end
        end
    end
end
function hop(num) 
    local time = {0.1,0.5,0.9,1.3,1.7}
    redstone.setOutput("top",true)--0.1,0.5,1,1.5,2
    sleep(time[num])
    redstone.setOutput("top",false)
end
function input(numbers,c)--({1,1,3,5},rc/gc)
    for o = 1, 4 do
        for i = 1, 4 - o do
            shovel.pushItems(peripheral.getName(loader),i,1,i)
        end
        mags.pushItems(peripheral.getName(loader),numbers[5-o],1,5-o)
        hop(4 - o)
        sleep(0.4) 
    end
    if c == "rc" then
        mags.pushItems(peripheral.getName(loader),7,1,5)
    elseif c == "gc" then
        mags.pushItems(peripheral.getName(loader),8,1,5)
    end
end 
function stop()
    sleep(10)
    for i = 1 ,6 do
        if mags.list()[i]["count"] <= 6 then
            stop()
        end
    end
end
function step(simulateAnswer1,numbers1,c) --return mutiple results
    local b,numbers,simulateAnswer = {0,0,0}
    numbers = tableCopy(numbers1)
    simulateAnswer = tableCopy(simulateAnswer1)
    local jundge = nil
    for i = 1, 4 do
        if simulateAnswer[i] == numbers[i] then
            b[3] = b[3] + 1
            simulateAnswer[i] = nil
            numbers[i] = nil
        end
    end
    for i = 1 ,4 do
        if simulateAnswer[i] then
            for j = 1 ,4 do 
                if simulateAnswer[i] == numbers[j] then
                    b[2] = b[2] + 1
                    simulateAnswer[i] = 7
                    numbers[j] = 7
                    break
                end
            end
        end
    end
    b[1] = 4 - b[2] - b[3]
    local d = {b}
    local count = 1
    if c == "gc" then
        for i =1,4 do 
            if not simulateAnswer[i] then
                d[count] = tableCopy(b)
                d[count][4] = simulateAnswer1[i]
                count = count + 1
            end
        end
    elseif c == "rc" then
        for i = 1,4 do 
            if simulateAnswer[i] == 7 then
                d[count] = tableCopy(b)
                d[count][4] = simulateAnswer1[i] 
                count = count + 1
            end
        end
    end
    return d
end
local function answerFilter(log,answers1)
    local answers,count,jundge,answers2 = {},1,true,{}
    if not answers1 then
        for i1 = 1,6 do
        for i2 = 1,6 do
        for i3 = 1,6 do
        for i4 = 1,6 do
            answers[count] = {i1,i2,i3,i4}
            count = count+1
        end end end end
        answers2 = tableCopy(answerFilter(log,answers))
    else 
        answers = tableCopy(answers1) 
        for i,j in pairs(answers) do
            for i6 = 1,#log do
                if log[i6]["stepNumber"] and not tableCompare1(step(j,log[i6]["stepNumber"],"rc"),log[i6]["result"]) then 
                    jundge = nil 
                    break 
                end
            end
            if jundge then
                answers2[count] = j
                count = count+1
            else jundge = true
            end
        end
    end
    return answers2
end
function translate(table)
    local b = {0,0,0}
    --output table b{[ash],[minecraft:redstone],[minecraft:glowstone_dust],[catalysed number]}
    if analyser.list()[2]["name"] == "darkerdepths:ash" then
        b[1] = analyser.list()[2]["count"]
        if analyser.list()[3] then
            if analyser.list()[3]["name"] == "minecraft:redstone" then
                b[2] = analyser.list()[3]["count"]
                if analyser.list()[4] then
                    b[3] = analyser.list()[4]["count"]
                else b[3] = 0
                end
            elseif analyser.list()[3]["name"] == "minecraft:glowstone_dust" then
                b[2] = 0 
                b[3] = analyser.list()[3]["count"]
            else
                print("analyser_trash")
            end
        end
    elseif analyser.list()[2]["name"] == "minecraft:redstone" then
        b[1] = 0 
        b[2] = analyser.list()[2]["count"]
        if analyser.list()[3] then
            b[3] = analyser.list()[3]["count"]
        end
    else
        print("analyser_trash")
    end
    if shovel.list()[5] then
        b[4] = table[shovel.getItemDetail(5).displayName]
    end
    return b
end
function suggestedInfoValue(a)
    if a == 1 then print("error a == 1") end
    local b = {2,6,12,20,30}
    if a <= 6 then
        return b[a-1]
    elseif a <= 16 then
        return 0.8809*a^2 - 1.158*a + 1
    else
        return 0.7435*a^2 + 3.3087*a + 1
    end
end
function stepInstruct(log1,answers1)
    local log = tableCopy(log1)
    local answers,infoValue,count = nil,0,#log+1
    if answers1 then
        answers = tableCopy(answers1)
    end
    answers = answerFilter(log,answers)
    if #answers == 1 then
        return {answers[1],answers}
    end
    local sInfoV = suggestedInfoValue(#answers)
    for k =1,80 do
        log[count] = {["stepNumber"] =  {math.random(1,6),math.random(1,6),math.random(1,6),math.random(1,6)}}
        for i,j in pairs(answers) do
            local temporary = step(j,log[count]["stepNumber"],"rc")
            for m,n in pairs(temporary) do 
                log[count]["result"] = tableCopy(j)
                infoValue = infoValue + (#answers - #answerFilter(log,answers))/#temporary
            end
        end
        if infoValue >= sInfoV then
            return {log[count]["stepNumber"],answers}
        end
    end
    printTable("sInfo "..tostring(sInfoV).." too bigger than "..tostring(infoValue))
    print("#answers = "..tostring(#answers))
    error("please restart the program",0)
end
function printTable(a)
    if type(a) == "string" then
        io.write(a)
    elseif type(a) == "number" then
        io.write(tostring(a))
    elseif type(a) == "table" then
        local count,jundge = 1,nil
        io.write("{")
        for i,j in pairs(a) do
            if jundge then
                io.write(",")
            else
                jundge = true
            end
            if i == count then
                count = count + 1
            elseif type(i) == "string" then 
                io.write( '["'..i..'"]=')
            else io.write( '['..i..']=') end
            printTable(j)
        end
        io.write("}")
    end
end

function main()
    local table = {}
    for i=1,6 do
        table[mags.getItemDetail(i).displayName] = i
    end
    local log,count,answers = {{["stepNumber"] = {1,2,3,4}}},0,nil
    --local read = io.read() 
    if true then
        repeat 
            count = count + 1
            print("the number "..count.." round")
            input(log[count]["stepNumber"],"rc")
            redstone.setOutput("right",true)
            sleep(0.2)
            redstone.setOutput("right",false)
            sleep(5)
            hop(3)
            sleep(0.5)
            shovel.pushItems(peripheral.getName(analyser),4,1)
            repeat sleep(1) until analyser.list()[2] 
            log[count]["result"] = translate(table) 
            for i = 2 ,4 do
                analyser.pushItems(peripheral.getName(bottler),i,64) 
            end          
            shovel.pushItems(peripheral.getName(mags),5,1)
            local temporary = stepInstruct(log,answers)
            answers = tableCopy(temporary[2])
            log[count+1] = {["stepNumber"] = tableCopy(temporary[1])}
            if #answers == 1 then
                print("finish")
                printTable(answers[1])
                print(" ")
                break
            end
        until nil
    end
end
main()