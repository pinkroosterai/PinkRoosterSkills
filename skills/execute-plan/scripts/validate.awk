# Constrained Markdown parser: the skill templates, not arbitrary CommonMark.
function fail(s) { print "FAIL: " s; errors++ }
function note(s) { print "NOTE: " s }
function trim(s) { sub(/^[ \t]+/,"",s); sub(/[ \t]+$/, "",s); return s }
function clean(s,    p,q) {
  # State belongs to one input stream. Strip multiline HTML comments before fences.
  while (1) {
    if (comment) { p=index(s,"-->"); if (!p) return ""; s=substr(s,p+3); comment=0 }
    p=index(s,"<!--"); if (!p) break
    q=index(substr(s,p+4),"-->")
    if (q) s=substr(s,1,p-1) substr(s,p+q+6)
    else { s=substr(s,1,p-1); comment=1; break }
  }
  if (s ~ /^ *```/ || s ~ /^ *~~~/) { fence=!fence; return "" }
  return fence ? "" : s
}
function value(s) { sub(/^\*\*[^*]+\*\* *— */, "",s); return trim(s) }
function slug(s) { sub(/^#+ +/,"",s); sub(/ +#+ *$/, "",s); gsub(/[`*_]/,"",s); s=tolower(s); gsub(/—|–|·|…|“|”|‘|’/,"",s); gsub(/[^[:alnum:]_ \200-\377-]/,"",s); gsub(/ /,"-",s); return s }
function exists(path,    s,r) { r=(getline s < path); close(path); return r>=0 }
function normalize(path,    a,n,i,j,out,b) {
  n=split(path,a,"/"); j=0
  for (i=1;i<=n;i++) { if (a[i]=="" || a[i]==".") continue; if (a[i]=="..") { if (j) j-- } else b[++j]=a[i] }
  out=""; for (i=1;i<=j;i++) out=out "/" b[i]; return out
}
function pathof(dir,target) { return normalize(target ~ /^\// ? target : dir "/" target) }
function reciprocal(path,    s,t,dir,p,c,f,inrelated,found) {
  dir=path; sub(/\/[^/]*$/,"",dir)
  c=comment; f=fence; comment=0; fence=0
  while ((getline s < path)>0) {
    s=clean(s)
    if (s ~ /^## /) inrelated=(s=="## Related")
    if (!inrelated) continue
    while (match(s,/\]\([^)]*\)/)) {
      t=substr(s,RSTART+2,RLENGTH-3); s=substr(s,RSTART+RLENGTH)
      sub(/^</,"",t); sub(/>.*/,"",t); sub(/#.*/,"",t)
      if (pathof(dir,t)==normalize(base "/" ENVIRON["VALIDATE_FILE"])) found=1
    }
  }
  close(path); comment=c; fence=f; return found
}
function anchor(path,id,    s,k,n,seen,c,f) {
  c=comment; f=fence; comment=0; fence=0
  while ((getline s < path)>0) {
    s=clean(s)
    if (s ~ /^#+ /) { k=slug(s); n=seen[k]++; if (n) k=k "-" n; if (k==id) { close(path); comment=c; fence=f; return 1 } }
  }
  close(path); comment=c; fence=f; return 0
}
function links(s,dir,checkreverse,    x,t,p,h,path,line,found) {
  # Inline code is excluded. Angle-wrapped destinations support spaces.
  gsub(/`[^`]*`/,"",s)
  if (s ~ /\]\[[^]]*\]/ || s ~ /^ *\[[^]]+\]:/) fail("reference-style Markdown links require inline destinations")
  while (match(s,/\]\([^)]*\)/)) {
    x=substr(s,RSTART+2,RLENGTH-3); s=substr(s,RSTART+RLENGTH)
    if (x ~ /^</) { sub(/^</,"",x); sub(/>.*/,"",x) }
    else if (x ~ /[ \t]/) { fail("use <...> around link paths containing spaces: " x); continue }
    t=x; if (t ~ /^[a-zA-Z][a-zA-Z0-9+.-]*:/) continue
    p=index(t,"#"); h=""; if (p) { h=substr(t,p+1); t=substr(t,1,p-1) }
    if (t ~ /%/) { fail("percent-encoded local destinations are unsupported: " t); continue }
    path=t=="" ? base "/" ENVIRON["VALIDATE_FILE"] : pathof(dir,t)
    if (t=="" && h!="") { if (!(h in headings)) fail("missing local anchor #" h); continue }
    if (!exists(path)) { fail("missing link " path); continue }
    if (h!="" && !anchor(path,h)) fail("missing anchor " x)
    if (checkreverse && t!="") {
      if (!reciprocal(path)) fail("Related link lacks reciprocal link: " t)
    }
  }
}
function citations(s,    x,n) {
  gsub(/`[^`]*`/,"",s)
  while (match(s,/\[[0-9]+\]/)) { n=substr(s,RSTART+1,RLENGTH-2)+0; cited[n]=1; s=substr(s,RSTART+RLENGTH) }
}
function flushdecision(    a,t) {
  if (decision=="") return
  if (match(decision,/superseded by D[0-9]+/)) { t=substr(decision,RSTART,RLENGTH); sub(/superseded by /,"",t); superseded[id]=t; rest=substr(decision,RSTART+RLENGTH); if (rest ~ /superseded by/) fail("multiple supersessions for " id) }
  else if (decision ~ /superseded by/) fail("malformed supersession for " id)
  else { total++; if (decision ~ /confirmed [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) confirmed++; else if (index(decision,"`assumed`")) assumed++ }
  decision=""
}
function finishphase(    k) {
  if (!phase) return
  if (ps !~ /^(not started|in progress|blocked|done)$/) fail("invalid phase status: " phase)
  if (ps=="done" && unchecked) fail("done phase has unchecked tasks: " phase)
  if (ps!="done" && !first) { first=phase; firststatus=ps }
  for (k in fields) if (!phasefields[k] && !(legacy && (k=="Rests on" || k=="Settle first"))) fail("phase " phase " lacks " k)
  delete phasefields; unchecked=0
}
BEGIN {
  base=ENVIRON["VALIDATE_BASE"]; root=ENVIRON["VALIDATE_ROOT"]
  fields["Status"]=1; fields["Rests on"]=1; fields["Settle first"]=1; fields["Done when"]=1; fields["Tasks"]=1
  if (mode!="spec" && mode!="plan" && mode!="corpus" && mode!="backlog") { fail("unknown validator mode"); exit 2 }
}
{
  s=clean($0); lines[NR]=s
  if (s ~ /^#+ /) { h=slug(s); hn=headingcounts[h]++; if (hn) h=h "-" hn; headings[h]=1 }
  if (s ~ /^## /) { section=s; sub(/^## /,"",section); sections[section]=1 }
  if (mode=="spec") {
    if (s ~ /^## /) flushdecision()
    if (s ~ /^\*\*(Status|Confirmed|Coverage)\*\*/) { k=s; sub(/^\*\*/,"",k); sub(/\*\*.*/,"",k); if (headers[k]++) fail("duplicate " k); header[k]=value(s) }
    if (index(s,"[BLOCKING")) blocking++
    if (section=="Decisions" && s ~ /^- /) {
      flushdecision(); id=$2
      if (id !~ /^D[0-9]+$/) fail("decision lacks D<n> ID")
      if (ids[id]++) fail("duplicate decision " id)
      decision=s
    } else if (section=="Decisions" && s ~ /^  /) decision=decision " " s
  }
  if (mode=="plan") {
    if (s ~ /^## Phase /) {
      finishphase(); phase=++phases; split(s,a," "); if (a[3]+0!=phase) fail("phase numbering must be sequential")
    } else if (s ~ /^## /) { finishphase(); phase=0 }
    if (s ~ /^\*\*[^*]+\*\*/) {
      k=s; sub(/^\*\*/,"",k); sub(/\*\*.*/,"",k)
      if (phase) { if (phasefields[k]++) fail("duplicate phase field " k); if (k!="Tasks" && value(s)=="") fail("empty phase field " k); if (k=="Status") ps=value(s) }
      else { if (planfields[k]++) fail("duplicate plan header " k); planheader[k]=value(s) }
    }
    if (s ~ /^- \[[ xX]\]/ && phase) { tasks++; if (s ~ /^- \[ \]/) unchecked++ }
    if (s ~ /user.*overrode.*[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ && section=="Context") override=1
    if (phase && phasefields["Done when"]) acceptance=acceptance "\n" s
  }
  if (mode=="corpus" || mode=="backlog") {
    if (section=="Sources" && s ~ /^[0-9]+\. /) {
      n=s+0; if (sources[n]++) fail("duplicate source number " n)
      if (match(s,/https?:\/\/[^ <>)]*/)) { u=substr(s,RSTART,RLENGTH); if (urls[u]++) fail("duplicate source URL " u) }
      else fail("source lacks URL: " n)
    } else if (section!="Sources") citations(s)
    if (ENVIRON["VALIDATE_SCRATCH"]!="" && index(s,ENVIRON["VALIDATE_SCRATCH"])) fail("scratch path leaked at line " NR)
    related[NR]=(section=="Related")
  }
  if (mode=="backlog") {
    if (section=="Needs" && s ~ /^- \*\*N[0-9]+\*\*/) { x=s; sub(/^.*\*\*N/,"",x); sub(/\*\*.*/,"",x); if (needs[x]++) fail("duplicate need N" x) }
    if (s ~ /^### I[0-9]+ /) { split(s,a," "); idea=substr(a[2],2)+0; if (ideas[idea]++) fail("duplicate idea I" idea); if (idea>maxid) maxid=idea }
    if (section=="Ranked ideas" && s ~ /^\| *[0-9]+ *\|/) {
      split(s,a,"|"); rank=trim(a[2])+0; if (ranks[rank]++) fail("duplicate rank " rank)
      x=trim(a[3]); sub(/^I/,"",x); sub(/[^0-9].*/,"",x); row=x+0
      if (rows[row]++) fail("duplicate ranked idea I" row)
      n=trim(a[4]); sub(/^N/,"",n); if (n !~ /^[0-9]+$/) fail("malformed need reference"); rowneed[row]=n
      rowstatus[row]=trim(a[8])
    }
    if (s ~ /^- \*\*Status\*\*/) detailstatus[idea]=value(substr(s,3))
    if (section=="Rejected" && s ~ /^- \*\*I[0-9]+ /) { x=s; sub(/^- \*\*I/,"",x); sub(/[^0-9].*/,"",x); if (rejected[x]++) fail("duplicate rejected idea"); if (x+0>maxid) maxid=x+0 }
  }
}
END {
  if (comment || fence) fail("unclosed comment or code fence")
  if (NR==0) fail("empty input")
  if (mode=="spec") {
    flushdecision()
    if (!("Decisions" in sections)) fail("missing Decisions section")
    for (id in superseded) {
      t=superseded[id]; if (!(t in ids)) fail("missing supersession target " t)
      delete seen; t=id
      while (t in superseded) { if (seen[t]++) { fail("supersession cycle at " t); break } t=superseded[t] }
    }
    expected=(confirmed+0) "/" (total+0) " decisions · " (assumed+0) " assumed, unconfirmed"
    if (header["Confirmed"]!=expected) fail("Confirmed must be " expected)
    status=header["Status"]
    if (status !~ /^(draft|shaping|buildable)$/) fail("invalid or missing Status")
    if ("Coverage" in header) {
      split(header["Coverage"],a," "); split(a[1],b,"/"); clear=b[1]+0; partial=a[4]+0; missing=a[7]+0
      if (header["Coverage"] !~ /^[0-9]+\/9 clear · [0-9]+ partial · [0-9]+ missing$/ || clear+partial+missing!=9) fail("invalid Coverage arithmetic")
    }
    if (status=="buildable" && (blocking || missing || confirmed!=total)) fail("buildable with blocking marks, missing categories or unconfirmed decisions")
  }
  if (mode=="plan") {
    finishphase()
    if (!phases) fail("no phases")
    if (!planheader["Goal"] || !planheader["Research"]) fail("missing Goal or Research")
    if ((phases>maxp || tasks>maxt) && !override) fail("plan exceeds phase/task limit without dated user override")
    expected=first ? (firststatus=="not started" ? "not started" : "phase " first " " firststatus) : "done"
    if (first && firststatus=="not started" && first>1) { if (planheader["Status"]!="not started") fail("header disagrees with first unfinished phase") }
    else if (planheader["Status"]!=expected) fail("plan Status must be " expected)
    if (planheader["Milestone"]!="") milestone()
  }
  if (mode=="corpus" || mode=="backlog") {
    if (!("Sources" in sections)) fail("missing Sources section")
    if (mode=="corpus" && root=="") fail("--root is required for corpus checks")
    for (n in cited) if (!(n in sources)) fail("citation has no source: " n)
    for (n in sources) if (!(n in cited)) fail("unused source: " n)
    for (i=1;i<=NR;i++) links(lines[i],base,mode=="corpus" && related[i])
  }
  if (mode=="backlog") {
    if (!("Needs" in sections) || !("Ranked ideas" in sections)) fail("missing backlog sections")
    for (x in rows) {
      if (!(x in ideas)) fail("ranked idea lacks detail I" x)
      if (!(rowneed[x] in needs)) fail("unknown need N" rowneed[x])
      if (rowstatus[x]!=detailstatus[x]) fail("table/detail status mismatch I" x)
    }
    for (x in ideas) {
      if (!(x in rows) && !(x in rejected)) fail("idea absent from ranking/rejected I" x)
      if (detailstatus[x] !~ /^(candidate|parked \(.+, [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)|rejected \(.+, [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)|specced → .+ \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\))$/) fail("invalid idea status I" x)
    }
    baseline=ENVIRON["VALIDATE_BASELINE"]
    if (baseline!="") {
      comment=0; fence=0
      while ((getline s < baseline)>0) {
        s=clean(s)
        if (s ~ /^- \*\*N[0-9]+\*\*/) { n=s; sub(/^- \*\*N/,"",n); sub(/\*\*.*/,"",n); oldneeds[n]=1; if (n+0>oldneedmax) oldneedmax=n+0 }
        if (s ~ /^### I[0-9]+ / || s ~ /^- \*\*I[0-9]+ /) { sub(/^### I|^- \*\*I/,"",s); sub(/[^0-9].*/,"",s); old[s+0]=1; if (s+0>oldmax) oldmax=s+0 }
      }
      close(baseline)
      for (x in oldneeds) if (!(x in needs)) fail("removed historical need N" x)
      for (x in needs) if (!(x in oldneeds) && x+0<=oldneedmax) fail("new need below historical maximum N" x)
      for (x in old) if (!(x in ideas) && !(x in rejected)) fail("removed historical ID I" x)
      for (x in ideas) if (!(x in old) && x<=oldmax) fail("new ID below historical maximum I" x)
    }
  }
  if (!errors) print "OK: " mode " mechanical checks passed"
  exit errors ? 1 : 0
}
function milestone(    m,path,s,k,v,ms,sp,pl,c,f,criteria,doneblock,title,specdir,indexpath) {
  m=planheader["Milestone"]; split(m,a," "); identity=a[1]
  if (!match(m,/`[^`]+`/)) { fail("Milestone header lacks document path"); return }
  path=base "/" substr(m,RSTART+1,RLENGTH-2)
  if (!exists(path)) { fail("missing milestone document"); return }
  c=comment; f=fence; comment=0; fence=0
  while ((getline s < path)>0) {
    s=clean(s)
    if (s ~ /^# Milestone /) { title=1; if (index(s,"# Milestone " identity " ")!=1) fail("milestone identity mismatch") }
    if (s ~ /^\*\*Status\*\*/) ms=value(s)
    if (s ~ /^\*\*Spec\*\*/) { sp=value(s); gsub(/`/,"",sp) }
    if (s ~ /^\*\*Plan\*\*/) { pl=value(s); gsub(/`/,"",pl) }
    if (s ~ /^\*\*/) doneblock=(s ~ /^\*\*Done when\*\*/)
    if (doneblock) { v=s ~ /^\*\*Done when/ ? value(s) : trim(s); if (v!="") { criteria++; if (!index(acceptance,v)) fail("milestone acceptance missing from plan") } }
  }
  close(path); comment=c; fence=f
  if (!title) fail("missing milestone identity heading")
  if (!criteria) fail("missing milestone acceptance")
  expectedms=planheader["Status"]=="done" ? "done" : planheader["Status"]=="not started" ? "planned" : "in progress"
  if (ms!=expectedms) fail("milestone/plan status mismatch")
  if (pl!=ENVIRON["VALIDATE_FILE"]) fail("milestone Plan backlink mismatch")
  if (sp=="" || !exists(base "/" sp)) { fail("missing milestone Spec backlink"); return }
  found=0; specdir=normalize(base "/" sp); sub(/\/[^/]*$/,"",specdir)
  while ((getline s < (base "/" sp))>0) {
    if (index(s,"- " identity " — ")==1 && index(s," — " ms " — ") && match(s,/`[^`]+`/)) {
      indexpath=substr(s,RSTART+1,RLENGTH-2)
      if (pathof(specdir,indexpath)==normalize(path)) found=1
    }
  }
  close(base "/" sp)
  if (!found) fail("spec milestone index missing or status mismatch")
}
