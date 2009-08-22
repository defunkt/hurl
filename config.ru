app = proc do |env|
    [200, { "Content-Type" => "text/html" }, ["hi <b>world</b>"]]
end
run app