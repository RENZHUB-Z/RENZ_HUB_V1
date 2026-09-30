-- RENZ HUB | MADE BY RENZ
local src = game:HttpGet("https://raw.githubusercontent.com/sabscrip-arch/srver/refs/heads/main/Stealanegg")

-- Palitan yung title text
src = src:gsub("rene baterbonia | By renehubs v2.0", "RENZ HUB | By RENZ")
src = src:gsub("rene baterbonia", "RENZ")
src = src:gsub("By renehubs v2.0", "By RENZ")
src = src:gsub("renehubs v2.0", "RENZ")

-- Tanggalin yung Owner button text
src = src:gsub('"Owner"', '" "')
src = src:gsub("'Owner'", "' '")

loadstring(src)()

-- Extra safety: hanapin sa UI pag nag-load na at burahin Owner
task.delay(2, function()
  for _,v in pairs(game:GetService("CoreGui"):GetDescendants()) do
    if v:IsA("TextLabel") and v.Text:lower():find("rene") then
      v.Text = "RENZ HUB | By RENZ"
    end
    if v.Text == "Owner" or v.Text == " " then
      if v.Parent and v.Parent.Name:lower():find("owner") or v.Text == "Owner" then
        pcall(function() v.Parent.Visible = false end)
        pcall(function() v:Destroy() end)
      end
    end
  end
end)
