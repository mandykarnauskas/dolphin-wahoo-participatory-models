####   code for averaging and plotting stakeholder graphs         ####
####   calculates average seasonal trends from digitized graphs   ####

rm(list=ls())
setwd("C:/Users/mandy.karnauskas/Desktop/participatory_workshops/stakeholder_plots_SA/digitized_data")
library(pals)
library(yarrr)

# subset list ----------------------------------------------------

lis <- dir()
length(lis)

lis2 <- lis[grep("charter", lis)]
#lis2 <- lis[grep("historical_comm", lis)]
#lis2 <- lis[grep("present_comm", lis)]

lis2 <- lis2[grep("VB", lis2)]
lis2

# check raw data -------------------------------------------------

par(mfrow = c(3,2), mex = 0.3)
for (i in 1:length(lis2))  { 
    d <- read.table(lis2[i], sep=",", header=F)
    plot(NA, xlim = c(0, 13), ylim = c(0,15), main = substr(lis2[i], 1, nchar(lis2[i])-3), cex.main = 0.8)
    cols <- 1
    for (j in unique(d$V3))  { 
        lines(d$V1[which(d$V3 == j)], d$V2[which(d$V3 == j)], lwd = 2, col = cols)
        points(d$V1[which(d$V3 == j)], d$V2[which(d$V3 == j)], pch=20, col = cols, cex=2)
        cols <- cols + 1
        }
    legend("top", as.character(unique(d[,3])), lwd = 2, col = 1:cols, ncol = 2, cex = 0.8)
    }

# concatenate all data into single matrix --------------------------
alldat <- data.frame(matrix(ncol = 4, nrow = 0))

for (i in 1:length(lis2))  { 
    d <- read.table(lis2[i], header=F, sep=",", stringsAsFactors=F)
    splis <- as.character(unique(d$V3))
    d$V1 <- round(d$V1)
    for (j in splis)  {
        mismon <- which(1:12 %in% d$V1[which(d$V3==j)]==F)
        if (length(mismon > 0))  {
           nd <- data.frame(cbind(mismon, rep(0, length(mismon)), j))
           names(nd) <- names(d)
           d <- rbind(d, nd)    } 
        }
    d$V1 <- as.numeric(d$V1)
    d$V2 <- as.numeric(d$V2)
    d <- d[order(d$V3, d$V1),]
    d$V4 <- d$V2/max(d$V2)
    d$V5 <- i
    alldat <- rbind(alldat, d)    
    print(table(alldat$V1, alldat$V3))
    }
    
names(alldat) <- c("mon", "orig", "spp", "scal", "ID")
head(alldat)
colMeans(table(alldat$mon, alldat$spp))

plot(alldat$orig, alldat$scal, col = alldat$ID)  # check scaling

# combine different names for same species --------------------
alldat$spp <- as.character(alldat$spp)
unique(alldat$spp)

tuna_lis <- c("BFT", "blackfin tuna", "tuna", "yellowfin tuna", "bluefin tuna")
sngr_lis <- c("grouper", "bottomfish", "snapper-grouper")
mahi_lis <- c("dolphin", "mahi")
king_lis <- c("KMK", "king mackerel")
bill_lis <- c("billfish", "marlin", "blue marlin", "white marlin")
shar_lis <- c("mako", "sharks")
insh_lis <- c("inshore", "striper")
crok_lis <- c("kingfish", "seamullet", "croaker")

alldat$sp2 <- alldat$spp
alldat$sp2[which(alldat$spp %in% tuna_lis)] <- "tunas"
alldat$sp2[which(alldat$spp %in% sngr_lis)] <- "snapper-grouper"
alldat$sp2[which(alldat$spp %in% mahi_lis)] <- "mahi"
alldat$sp2[which(alldat$spp %in% king_lis)] <- "king mackerel"
alldat$sp2[which(alldat$spp %in% bill_lis)] <- "billfishes"
alldat$sp2[which(alldat$spp %in% shar_lis)] <- "sharks"
alldat$sp2[which(alldat$spp %in% insh_lis)] <- "inshore spp"
alldat$sp2[which(alldat$spp %in% crok_lis)] <- "croakers"

table(alldat$spp, alldat$sp2)

# sort list and create plot settings -----------------------------

sort(table(alldat$sp2), decreasing = T)
relis <- names(sort(table(alldat$sp2), decreasing = T))
a <- match(c("mahi", "wahoo"), relis)
relis <- c(relis[a], relis[-a])
relis
alldat$sp2 <- factor(alldat$sp2, levels = relis)
unique(alldat$sp2)

lwds <- colMeans(table(alldat$mon, alldat$sp2)) 
lwds

cols <- cols25(25)
relis

sporder <- c("croakers", "wahoo", "snapper-grouper", "billfishes", "sharks", "mahi", "tunas", 
             "bluefish", "spanish mackerel", "tilefish", "swordfish", "shrimp", "king mackerel")


# barplot of average dependence ----------------------------------
par(mfrow = c(1, 1))
avdep <- tapply(alldat$scal, list(alldat$mon, alldat$sp2), mean)
avdep
barplot(t(avdep), legend.text = colnames(avdep), args.legend = list(x = "topleft"), col = rainbow(11))

# plot raw data and check smoothing ------------------------------

par(mfrow = c(4, 4))
for (j in 1:length(relis)) {
    plot(NA, axes = F, ylim = c(0, 1.3), xlim = c(1, 12), ylab = "", xlab = "", main = relis[j])
    axis(1, at=1:12, month.abb, cex.axis=1.2); box()
    axis(2, at=c(0, 0.1, 1), lab=c("none", "low", "high"), las=2, cex.axis=1.2)
    for (i in 1:max(alldat$ID)) { 
        f <- alldat[which(alldat$ID == i),]
        a <- which(f$sp2 == relis[j]) 
        lines(f$mon[a], f$scal[a], col = cols[j], lwd = 1)
    }   
    f <- alldat[which(alldat$sp2 == relis[j]),]
    fmean <- tapply(f$scal, f$mon, mean)
    fse <- tapply(f$scal, f$mon, sd) / sqrt(length(unique(f$ID)))
    ksmean <- ksmooth(1:12, fmean, "normal", bandwidth=1.5, range.x=c(1,12), n.points=12)
    ksse <- ksmooth(1:12, fse, "normal", bandwidth=1, range.x=c(1,12), n.points=12)
    upper <- ksmean$y + ksse$y
    lower <- ksmean$y - ksse$y
    lines(ksmean$y, col = cols[j], lwd=2)
    polygon(x = c(1:12, 12:1), y = c(upper, lower[12:1]), 
            border = NA, col = transparent(cols[j], trans.val = 0.5))
    }

# plot mean +/- 1 S.E. of species with n > 2 ------------------------------------

#li <- which(table(alldat$sp2) > 24)
li <- c(which(names(table(alldat$sp2)) == "mahi"),  which(table(alldat$sp2) > 12)); li
#li <- which(table(alldat$sp2) > 12); li

angles = seq(30, 180, length.out = length(li)+1)

png(filename=paste0("C:/Users/mandy.karnauskas/Desktop/participatory_workshops/stakeholder_plots_SA/", 
    "VB_charter.png"), units="in", width=8.3, height=6.5, pointsize=12, res=72*4)

par(mfrow = c(1, 1), mgp = c(1, 1, 0))

plot(NA, axes = F, ylim = c(0, 1.0), xlim = c(1, 96), xlab = "", ylab = "")
mtext(side = 2, cex = 1.1, line = 1.5, "dependence on species or species group")
axis(1, at=seq(4, 96, 8), month.abb, cex.axis=1.2); box()
axis(2, at=c(0, 1), lab=c("low", "high"), las=2, cex.axis=1.2)
for (j in li) {
    f <- alldat[which(alldat$sp2 == relis[j]),]
    fmean <- tapply(f$scal, f$mon, mean)
    fse <- tapply(f$scal, f$mon, sd) / sqrt(length(unique(f$ID)))
    ksmean <- ksmooth(1:12, fmean, "normal", bandwidth=1.5, range.x=c(1,12), n.points=96)
    ksse <- ksmooth(1:12, fse, "normal", bandwidth=1.5, range.x=c(1,12), n.points=96)
    upper <- ksmean$y + ksse$y
    lower <- ksmean$y - ksse$y
    lines(ksmean$y, col = cols[which(relis[j] == sporder)], lwd=3)
    polygon(x = c(1:96, 96:1), y = c(upper, lower[96:1]), 
            border = NA, col = transparent(cols[which(relis[j] == sporder)], trans.val = 0.9))
    #polygon(x = c(1:96, 96:1), y = c(upper, lower[96:1]), angle = angles[j], density = 15, 
    #        border = NA, col = transparent(cols[which(relis[j] == sporder)], trans.val = 0.7))
#   lines(seq(4, 96, 8), fmean)
}
legloc <- c(1, 1)
#legloc <- c(1, 1.15)
#legloc <- c(72, 1.03)
#legloc <- c(75, 0.475)
#legloc <- c(75, 0.3)
legend(x = legloc[1], y = legloc[2], ncol = 1, relis[li], col = cols[match(relis[li], sporder)], pch = NA,  
       lwd = 3, text.col = cols[match(relis[li], sporder)], pt.cex = 2, bty="n", x.intersp = 1)
legend(x = legloc[1], y = legloc[2], ncol = 1, relis[li], 
       col = transparent(cols[match(relis[li], sporder)], trans.val = 0.7), pt.cex = c(0, 2, 2, 2), 
       lwd = 1, lty = 0, pch = c(15, 15, 15, 15), text.col = cols[match(relis[li], sporder)], bty = "n", x.intersp = 1)

lis2
mtext(side = 3, line = 1, "Virginia Beach for-hire species dependency", font = 2, cex = 1.2)

dev.off()



# plot smoothed curves with no SE -------------------------------
avdepsm <- c()
for (i in 1:ncol(avdep))  {
    if (sum(avdep[,i]) > 1)  {
    ks <- ksmooth(1:12, avdep[,i], "normal", bandwidth=1.5, range.x=c(1,12), n.points=96) } else {
    ks <- ksmooth(1:12, avdep[,i], "normal", bandwidth=0.75, range.x=c(1,12), n.points=96)      }
    avdepsm <- cbind(avdepsm, ks$y) } 

windows()
matplot(avdepsm, type="l", lwd=lwds, lty = 1, col=cols[1:ncol(avdep)], axes=F, ylim=c(0, 1.3), ylab="")
mtext(side=2, line=1.5, "dependence on species or group", cex=1.2)
axis(1, at=seq(4, 96, 8), month.abb, cex.axis=1.2); box()
axis(2, at=c(0, 0.95), lab=c("low", "high"), las=2, cex.axis=1.2)
legend("topleft", colnames(avdep), lwd=lwds, lty=1, bty="n", col=cols[1:ncol(avdep)], ncol=2, x.intersp=1, cex=1.1)
legend(80, 1.3, c("n = 1", "n = 3", "n = 6"), lwd=c(1.5, 4.5, 9), y.intersp = 1.1)

###############################  END  #####################################